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
# pillar 可以直接使用 grains
# grains 在 minion 启动时候加载，而 pillar 在 master 执行 refresh_pillar 时，加载
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

### salt 匹配规则

- Globing: 默认匹配规则
  - salt '*' 匹配所有
  - salt '192.168.1.* test.ping' 匹配 minion id 中以 192.168.1 开头的
  - salt 'web[1-5] test.ping' 匹配 web1 到 web5
  - salt 'web[1,5] test.ping' 匹配 web1 和 web5
- 正则表达式
  - salt -E 'web-(dev|qa)' 匹配 web-dev 和 web-qa
  
  top file:
  ```salt
  base:
    'web-(dev|qa)':
      - match: pcre
      - packages
  ```
- List: 列表
  - salt -L 'web1,web2' 匹配 web1 和 web2
- Grains
  - salt -G 'os:Ubuntu' 匹配 grains 中 os 值为 Ubuntu

  top file:
  ```salt
  base:
    'os:Ubuntu':
      - match: grain
      - packages
  ```
- Pillar
  - salt -I 'roles:dev' 匹配 pillar 中 roles 值为 dev
- NodeGroup
  - salt -N 'web' 匹配 master 配置文件中，node group 为 web
    top file:
  ```salt
  base:
    'web':
      - match: nodeGroup
      - packages
  ```

### batch size

执行命令时，不想一次影响所有的机器，可以使用 `salt '*' -b 10/10% test.ping` -b 同时运行的 minion 数量/百分比

### salt 历史

- 查看执行的历史命令: salt-run jobs.list_jobs
- 查看历史命令的输出: salt-run jobs.lookup_jid 20210605021956477358
 
### salt master 分发文件

salt '*' cp.get_file salt://[salt master file] [remote file], 默认会去 /srv/salt 下找 master 文件

salt-cp [salt master file] [remote file]

## 配置管理

salt 使用 sls 文件进行配置的管理，默认路径为：srv/salt

salt state 文件 top.sls
```yaml
base:
  '*':
    - apache # 为对应模块的名字，模块下 init.sls 为默认配置文件
```

apache init.sls 配置文件
```yaml
apache:
  pkg.installed:
    - name: apache2
  file.managed: # 保证文件存在
    - names: # copy 多个文件
        - /etc/apache2/apache2.conf:
            - source: salt://apache/httpd.conf
        - /etc/apache2/ports.conf:
            - source: salt://apache/ports.conf
    - require: # 当 apache 模块的的 pkg 执行成功时，会触发当前 file.managed
        - pkg: apache # 第一行模块名
    - template: jinja # 指定渲染引擎
    - context: # 变量
        port: 8080
  service.running:
    - name: apache2
    - enable: True
    - watch: # 当 apache 模块下的 file 发生变化，会执行 service.running
        - file: apache

```


