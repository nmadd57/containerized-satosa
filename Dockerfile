FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends xmlsec1 \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir "satosa[idpy_oidc_backend]" gunicorn

COPY patch_satosa.py /tmp/patch_satosa.py
RUN python3 /tmp/patch_satosa.py && rm /tmp/patch_satosa.py

WORKDIR /opt/satosa/etc

EXPOSE 8000

CMD ["gunicorn", "-b", "0.0.0.0:8000", "--chdir", "/opt/satosa/etc", "satosa.wsgi:app"]
