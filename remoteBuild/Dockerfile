ARG CONTAINER_TAG

FROM jaynewstrom/alpine-gradle-android:${CONTAINER_TAG}

RUN apk add --no-cache --update \
        rsync \
        openssh \
    && rm -rf /var/cache/apk/* \
    && rm -f /etc/ssh/ssh_host_rsa_key \
    && echo "root:root" | chpasswd

COPY sshd_config /etc/ssh/.
COPY entrypoint.sh /.

CMD ["/entrypoint.sh"]
