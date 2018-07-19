# == Class: logstash2x::package
#
# This class exists to coordinate all software package management related
# actions, functionality and logical units in a central place.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'logstash2x::package': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
class logstash2x::package {

  Exec {
    path      => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd       => '/',
    tries     => 3,
    try_sleep => 10,
  }

  #### Package management

  # set params: in operation
  if $logstash2x::ensure == 'present' {

    # action
    if ($logstash2x::package_url != undef) {

      $package_dir = $logstash2x::package_dir

      # Create directory to place the package file
      exec { 'create_package_dir_logstash':
        cwd     => '/',
        path    => ['/usr/bin', '/bin'],
        command => "mkdir -p ${logstash2x::package_dir}",
        creates => $logstash2x::package_dir;
      }

      file { $package_dir:
        ensure  => 'directory',
        purge   => $logstash2x::purge_package_dir,
        force   => $logstash2x::purge_package_dir,
        backup  => false,
        require => Exec['create_package_dir_logstash'],
      }

    }

  } else { # Package removal
    $package_dir = $logstash2x::package_dir

    file { $package_dir:
      ensure => 'absent',
      purge  => true,
      force  => true,
      backup => false,
    }

  }

  #class { 'logstash2x::package::core': }
  logstash2x::package::install { 'logstash':
    package_url => $logstash2x::package_url,
    version     => $logstash2x::version,
  }
}
