xhost +local:root

sudo docker run -it --name vision --net=host -e DISPLAY=$DISPLAY -e QT_X11_NO_MITSHM=1 -v /tmp/.X11-unix:/tmp/.X11-unix:rw -v /dev/bus/usb:/dev/bus/usb --device-cgroup-rule='c 189:* rmw' --device-cgroup-rule='c 188:* rmw' --device-cgroup-rule='c 4:* rmw' --group-add video --group-add dialout mavision

