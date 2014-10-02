class microcosm::frontend {

    user { 'django':
        ensure     => 'present',
        comment    => 'Django user',
        managehome => false,
        gid        => 'microcosm',
        shell      => '/bin/bash',
        require    => Group['microcosm'],
    }

    # Python dependencies
    package { 'python2.7':
        ensure => installed,
    }

    package { 'python2.7-dev':
        ensure => installed,
    }

    package { 'libevent-dev':
        ensure => installed,
    }

    package { 'libmemcached-dev':
        ensure => installed,
    }

    package { 'python-virtualenv':
        ensure => installed,
    }

    # General directory structure and nginx config
    file { '/srv/www':
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0755',
    }

    file { '/srv/www/django':
        ensure  => directory,
        owner   => django,
        group   => microcosm,
        mode    => '0755',
        require => File['/srv/www'],
    }

    file { '/var/log/django':
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => '0755',
    }

    class { 'nginx':
        worker_processes   => 2,
        worker_connections => 1000,
        proxy_set_header   => [
            'Host $host',
            'X-Forwarded-For $proxy_add_x_forwarded_for',
        ],
        server_tokens      => 'off',
    }

    # Upstream server (gunicorn) listens on port 8000 on the loopback device
	nginx::resource::upstream { 'upstream':
		ensure  => present,
		members => ["127.0.0.1:8000"],
	}

    # A vhost that simply proxies requests to the upstream defined above
    # Change the server_name if using your own domain
	nginx::resource::vhost { 'microweb':
		ensure         => present,
		proxy          => 'http://microweb-upstream',
		listen_ip      => $frontend_listen_ip,
		listen_port    => $frontend_listen_port,
		listen_options => 'default_server',
		server_name    => ['dev.microco.sm',],
	}

    # A location for serving static files at /static
	nginx::resource::location { 'static':
		ensure   => present,
		location => '/static',
		www_root => '/srv/www/django/microweb',
		vhost    => 'microweb',
		require  => File['/srv/www/django/microweb'],
	}

	file { '/srv/www/django/microweb':
		ensure  => directory,
		owner   => django,
		group   => microcosm,
		mode    => '0755',
		require => File['/srv/www/django'],
	}

	file { '/etc/init/microweb.conf':
		ensure  => present,
		owner   => root,
		group   => root,
		mode    => '0755',
		source  => 'puppet:///modules/project_microcosm/etc/init/microweb.conf',
	}

	file { '/var/log/django/microweb.log':
		ensure => present,
		owner  => django,
		group  => microcosm,
		mode   => '0755',
	}

}
