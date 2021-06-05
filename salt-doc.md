# salt study doc

在 master 管理 salt key 工具：salt-key

- 列出所有 key: `salt-key -L`
    ```shell
    Accepted Keys:
    Denied Keys:
    Unaccepted Keys:
    192.168.1.10
    Rejected Keys:
    ```
- 接受所有 minion key: `salt-key -A`
- 接受指定 minion key: `salt-key -a [key name]`
- 删除所有 minion key: `salt-key -D`
- 删除指定 minion key: `salt-key -d [key name]`

查看 minion 是否在线: `salt '*' test.ping`

在 minion 执行命令: `salt '*' cmd.run 'echo hello world'`

## salt 数据系统

### grains

salt minion 元数据

- 存储在 minion 端，用来保存 minion 的数据信息
- 只有在 minion 启动的时候才会重新加载 grains

查看所有 grains: `salt '*' grains.items`

获取对应的 grains: `salt '*' grains.get pid`

### pillar

在 master 端存储的 salt 元数据，可以根据在 top.sls 文件中的配置，对不同的 minion 提供不同的配置

> pillar 默认路径: /srv/pillar
> 
> pillar 默认配置文件名: top.sls
> 
> 是否开启使用 pillar: pillar_opts: True

top.sls:
```salt
base:
  '*':
    - packages
```

pillar.sls:
```salt
{% if grains['os'] == 'Ubuntu' %}
apache: httpd
{% endif %}
```

- 存储在 master 端，存放需要提供给 minion 的信息
- 应用场景

    - 敏感信息: 每个 minion 只能访问 master 分配给自己的 pillar 信息
    - 变量: 差异化信息
    - 其他任何数据
    - 可以在 target 和 state 中使用