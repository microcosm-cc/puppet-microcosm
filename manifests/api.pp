class microcosm::api {

    user { 'microcosm':
        ensure     => 'present',
        comment    => 'microcosm service account',
        managehome => false,
        gid        => 'microcosm',
        shell      => '/bin/bash',
        require    => Group['microcosm'],
    }

	file { '/etc/microcosm':
		ensure  => directory,
		owner   => root,
		group   => root,
		mode    => '0777',
	}

	file { '/etc/microcosm/api.conf':
		ensure  => present,
		owner   => root,
		group   => root,
		mode    => '0644',
		content => template('project_microcosm/etc/microcosm/api.conf.erb'),
		require => File['/etc/microcosm'],
	}

	file { '/etc/init/microcosm.conf':
		ensure  => present,
		owner   => root,
		group   => root,
		mode    => '0755',
		source  => 'puppet:///modules/project_microcosm/etc/init/microcosm.conf',
		require => File['/etc/microcosm/api.conf'],
	}

	service { 'microcosm':
		ensure   => running,
		provider => 'upstart',
		require  => [File['/etc/init/microcosm.conf'],File['/var/log/microcosm'],File['/usr/sbin/microcosm']],
	}

	# Logs
	file { '/var/log/microcosm':
		ensure => directory,
		owner  => microcosm,
		group  => microcosm,
		mode   => '0755',
	}

	file { '/var/log/microcosm/error.log':
		ensure => present,
		owner  => microcosm,
		group  => microcosm,
		mode   => '0600',
	}

	file { '/var/log/microcosm/warn.log':
		ensure => present,
		owner  => microcosm,
		group  => microcosm,
		mode   => '0600',
	}

	file { '/var/log/microcosm/debug.log':
		ensure => present,
		owner  => microcosm,
		group  => microcosm,
		mode   => '0600',
	}
}
