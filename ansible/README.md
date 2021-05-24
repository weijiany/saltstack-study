minion.j2

master: {{ hostvars['master']['ansible_default_ipv4']['address'] }}，配置 salt master 地址

如果在 master.j2 中没有开启自动接受(auto_accept: False)，需要执行手动步骤才可以使 minion 和 master 进行连接

- 查看连接的状态: `salt-run manage.status`
- 删除已经连接的 minion 节点: `salt-key -d ubuntuMaster -y`
