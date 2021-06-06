apache:
  pkg.installed:
    - name: apache2
  file.managed:
    - names:
      - /etc/apache2/apache2.conf:
          - source: salt://apache/httpd.conf
      - /etc/apache2/ports.conf:
          - source: salt://apache/ports.conf
    - require:
        - pkg: apache
    - template: jinja
    - context:
        port: {{ salt['pillar.get']('apache:port') }}
  service.running:
    - name: apache2
    - enable: True
    - watch:
        - file: apache
