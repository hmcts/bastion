"""Print field names and template matches only; never print plan values."""
import base64
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent
TOKENS = ('UF_REMOVE', 'NESSUS_INSTALL', 'NESSUS_SERVER', 'NESSUS_KEY', 'NESSUS_GROUPS')


def match_template(script, template):
    parts = re.split(r'(\$\{(?:' + '|'.join(TOKENS) + r')\})', template)
    seen = set()
    pattern = []
    for part in parts:
        if part.startswith('${') and part[2:-1] in TOKENS:
            name = part[2:-1]
            pattern.append('(?P=' + name + ')' if name in seen else '(?P<' + name + '>.*?)')
            seen.add(name)
        else:
            pattern.append(re.escape(part))
    match = re.fullmatch(''.join(pattern), script, re.DOTALL)
    return match.groupdict() if match else None


def summarize(plan):
    results = []
    extra = (ROOT.parent / 'terraform/modules/bastion/ConfigureBastion.sh').read_text()
    templates = {name: (ROOT / ('bootstrap-' + name + '.sh.txt')).read_text() + '\n' + extra
                 for name in ('last-applied-era', 'current')}
    for resource in plan.get('resource_changes', []):
        change = resource['change']
        if resource.get('mode') != 'managed' or change['actions'] == ['no-op']:
            continue
        before, after = change.get('before') or {}, change.get('after') or {}
        result = {'address': resource['address'], 'actions': change['actions'],
                  'changed_fields': sorted(key for key in before.keys() | after.keys()
                                           if before.get(key) != after.get(key))}
        if resource['type'] == 'azurerm_virtual_machine_extension':
            for field in ('settings', 'protected_settings'):
                if field not in result['changed_fields']:
                    continue
                old = json.loads(before.get(field) or '{}')
                new = json.loads(after.get(field) or '{}')
                result[field + '_changed_keys'] = sorted(key for key in old.keys() | new.keys()
                                                        if old.get(key) != new.get(key))
                if 'script' in old and 'script' in new:
                    scripts = [base64.b64decode(item['script']).decode() for item in (old, new)]
                    matches = [{name: match_template(script, template) for name, template in templates.items()}
                               for script in scripts]
                    result['script_template_matches'] = [{name: value is not None for name, value in match.items()}
                                                         for match in matches]
                    captured = [next((value for value in match.values() if value is not None), None)
                                for match in matches]
                    if all(value is not None for value in captured):
                        result['script_parameter_changes'] = sorted(key for key in TOKENS
                                                                    if captured[0].get(key) != captured[1].get(key))
        results.append(result)
    return results


if __name__ == '__main__':
    try:
        print(json.dumps({'diagnostic_changes': summarize(json.load(sys.stdin))}, sort_keys=True))
    except Exception as error:
        print('Diagnostic summary failed: ' + type(error).__name__ + '; no values printed', file=sys.stderr)
        sys.exit(1)
