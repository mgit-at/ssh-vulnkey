# ssh-vulnkey

![Build Status](https://github.com/mgit-at/ssh-vulnkey/workflows/CI/badge.svg)
[![License](https://img.shields.io/badge/license-APACHE2-blue.svg?style=flat)](https://raw.githubusercontent.com/mgit-at/ssh-vulnkey/master/LICENSE)


Allows to check ssh keys against debian ssh key vulnerability database.


## Sample Usage

```shell
% ssh-vulnkey key1.pub key2.pub
```


## Testing

```shell
% make test
```


## Rationale

Debian removed the patch implementing ssh-vulnkey in openssh thus no tool was available anymore to check keys against the vulnerability databases as provided in openssh-blacklist(-extra).


## Idea

Also provide more generic RSA key checks for eg. known weak keys.


## License, Author

* License: Apache 2
* Author: Michael Gebetsroither <mgebetsroither@mgit.at>
