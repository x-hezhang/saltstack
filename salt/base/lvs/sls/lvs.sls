lvs_pkgs:
  pkg.installed:
    - pkgs:
      - ipvsadm
      - ipset
      - sysstat
      - libnetfilter_conntrack
      - libseccomp

lvs_modules:
  kmod.present:
    - mods:
      - ip_vs
      - ip_vs_rr
      - ip_vs_wrr
      - ip_vs_lc
      - ip_vs_wlc
      - ip_vs_sh
      - ip_vs_dh
      - nf_conntrack
      - br_netfilter

lvs_module_config:
  file.managed:
    - name: /etc/modules-load.d/ipvs.conf
    - source: salt://lvs/files/ipvs.conf
    - user: root
    - group: root
    - mode: 0644

lvs_hashtable_config:
  file.managed:
    - name: /etc/modprobe.d/ipvs.conf
    - source: salt://lvs/templates/ipvs.conf.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

lvs_modules_service:
  service.running:
    - name: systemd-modules-load
    - enable: True
    - watch:
      - file: lvs_module_config

lvs_rules_file:
  file.touch:
    - name: /etc/sysconfig/ipvsadm
    - unless:
      - test -f /etc/sysconfig/ipvsadm

lvs_rules_service:
  service.running:
    - name: ipvsadm
    - enable: True
    - require:
      - file: lvs_rules_file

lvs_ip_forward:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 1