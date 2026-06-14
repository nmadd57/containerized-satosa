FROM python:3.14-slim

RUN apt-get update && apt-get install -y --no-install-recommends xmlsec1 \
    && rm -rf /var/lib/apt/lists/*

# Pin to currently-verified versions so the weekly scheduled rebuild doesn't
# silently pick up an unreviewed release of a security-critical OIDC/SAML
# bridge; bump deliberately via dependabot/PR review.
RUN pip install --no-cache-dir "satosa[idpy_oidc_backend]==8.5.1" "gunicorn==26.0.0"

COPY patch_satosa.py /tmp/patch_satosa.py
RUN python3 /tmp/patch_satosa.py && rm /tmp/patch_satosa.py

WORKDIR /opt/satosa/etc

EXPOSE 8000

CMD ["gunicorn", "-b", "0.0.0.0:8000", "--chdir", "/opt/satosa/etc", "satosa.wsgi:app"]
