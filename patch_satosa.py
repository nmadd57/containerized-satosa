import sysconfig

# Work around a SATOSA bug: OIDC providers may return "amr" as a list
# (per spec it's an array of strings), but idpy_oidc.py's
# _translate_response uses it directly as the SAML AuthnContextClassRef
# text, which ElementTree cannot serialize if it's a list.
path = f"{sysconfig.get_paths()['purelib']}/satosa/backends/idpy_oidc.py"

with open(path) as f:
    content = f.read()

old = '        auth_class_ref = response.get("acr") or response.get("amr") or UNSPECIFIED\n'
new = (
    old
    + "        if isinstance(auth_class_ref, list):\n"
    + "            auth_class_ref = auth_class_ref[0] if auth_class_ref else UNSPECIFIED\n"
)

if old not in content:
    raise RuntimeError("patch target not found in idpy_oidc.py")

with open(path, "w") as f:
    f.write(content.replace(old, new, 1))
