### install
```bash
bash -s - --all <(curl -s https://raw.githubusercontent.com/jiemolabs/dev-setup/master/setup.sh)
#./setup.sh --all
```

### download failed

```bash
export http_proxy=http://example.com https_proxy=http://example.com
./setup.sh --all
```


### setuptools version conflict

    pip install --user ansible-2.1.0.0.tar.gz


### python-apt not available in virtualenv

    ln -s /usr/lib/python2.7/dist-packages/apt* $VIRTUAL_ENV/lib/python*/site-packages


### similar projects:
* https://github.com/thoughtbot/laptop

### references:
* https://robots.thoughtbot.com/laptop-setup-for-an-awesome-development-environment
* https://robots.thoughtbot.com/remote-development-machine
