#cloud-config
coreos:
  units:
    - name: "hanlonmk.service"
      command: "start"
      content: |
        [Unit]
        Description=Hanlon Microkernel container
        After=docker.service

        [Service]
        Restart=always
        ExecStart=/usr/bin/docker run --privileged=true --name=hanlon --net=host -e HANLON_SUBNETS=0.0.0.0/0 -e PERSIST_MODE=@json docker.ii.org.nz/iichip/hanlon:cncfci
        ExecStop=/usr/bin/docker rm -f hanlon
write_files:
  - path: /container-tmp-files/first_checkin.yaml
    permissions: 644
    owner: root
    content: |
      --- true
  - path: /container-tmp-files/mk_conf.yaml
    permissions: 644
    owner: root
    content: |
      mk_register_path: /hanlon/api/v1/node/register
      mk_uri: http://1.1.1.6:8026
      mk_checkin_interval: 60
      mk_checkin_path: /hanlon/api/v1/node/checkin
      mk_checkin_skew: 5
      mk_fact_excl_pattern: (^facter.*$)|(^id$)|(^kernel.*$)|(^memoryfree$)|(^memoryfree_mb$)|(^operating.*$)|(^osfamily$)|(^path$)|(^ps$)|(^ruby.*$)|(^selinux$)|(^ssh.*$)|(^swap.*$)|(^timezone$)|(^uniqueid$)|(^.*uptime.*$)|(.*json_str$)
      mk_log_level: Logger::ERROR
  - path: /container-tmp-files/mk-version.yaml
    permissions: 644
    owner: root
    content: |
      --- 
      mk_version: 3.0.1_dirty
  - path: /opt/rancher/bin/listen-cmd-channel.sh
    permissions: 755
    owner: root
    content: |
      #!/bin/bash
      [ -d /container-tmp-files/cmd-channels ] || mkdir /container-tmp-files/cmd-channels
      [ -e /container-tmp-files/cmd-channels/node-state-channel ] || mkfifo /container-tmp-files/cmd-channels/node-state-channel
      while read msg < /container-tmp-files/cmd-channels/node-state-channel; do
        if [ "$msg" = "reboot" ]; then
          reboot
        elif [ "$msg" = "poweroff" ]; then
          poweroff
        else
          echo "message '$msg' unrecognized"
        fi
      done
  - path: /opt/rancher/bin/start-mk.sh
    permissions: 755
    owner: root
    content: |
      #!/bin/bash

      # download Microkernel image from Hanlon server
      cd /tmp
      wget http://1.1.1.6:8026/hanlon/api/v1/image/mk/2YAL74TcnUjaO6k8fqr6tX/hanlon-mk-image.tar
      # wait until docker daemon is running
      prev_time=0
      sleep_time=1
      while true; do
        # break out of loop if docker daemon is in process table
        ps aux | grep `cat /var/run/docker.pid` | grep -v grep 2>&1 > /dev/null && break
        tmp_val=$((prev_time+sleep_time))
        prev_time=$sleep_time
        sleep_time=$tmp_val
        sleep $sleep_time
      done
      # load Microkernel image and start the Microkernel
      docker load -i hanlon-mk-image.tar
      docker run --privileged=true --name=hnl_mk -v /proc:/host-proc:ro -v /dev:/host-dev:ro -v /sys:/host-sys:ro -v /container-tmp-files:/tmp -d --net host -t `docker images -q` /bin/bash -c '/usr/local/bin/hnl_mk_init.rb && read -p "waiting..."'
  - path: /opt/rancher/bin/start.sh
    permissions: 755
    owner: root
    content: |
      #!/bin/bash
      /opt/rancher/bin/listen-cmd-channel.sh &
      /opt/rancher/bin/start-mk.sh &