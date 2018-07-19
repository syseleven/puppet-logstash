# == Class: logstash2x::config
#
# This class exists to coordinate all configuration related actions,
# functionality and logical units in a central place.
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
#   class { 'logstash2x::config': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
class logstash2x::config {
  File {
    owner => $logstash2x::logstash_user,
    group => $logstash2x::logstash_group,
  }

  $notify_service = $logstash2x::restart_on_change ? {
    true  => Class['logstash2x::service'],
    false => undef,
  }

  if ( $logstash2x::ensure == 'present' ) {
    file { $logstash2x::configdir:
      ensure  => directory,
      purge   => $logstash2x::purge_configdir,
      recurse => $logstash2x::purge_configdir,
    }

    file { "${logstash2x::configdir}/conf.d":
      ensure  => directory,
      require => File[$logstash2x::configdir],
    }

    file_concat { 'ls-config':
      ensure  => 'present',
      tag     => "LS_CONFIG_${::fqdn}",
      path    => "${logstash2x::configdir}/conf.d/logstash.conf",
      owner   => $logstash2x::logstash_user,
      group   => $logstash2x::logstash_group,
      mode    => '0644',
      notify  => $notify_service,
      require => File[ "${logstash2x::configdir}/conf.d" ],
    }

    $directories = [
      $logstash2x::patterndir,
      $logstash2x::plugindir,
      "${logstash2x::plugindir}/logstash",
      "${logstash2x::plugindir}/logstash/inputs",
      "${logstash2x::plugindir}/logstash/outputs",
      "${logstash2x::plugindir}/logstash/filters",
      "${logstash2x::plugindir}/logstash/codecs",
    ]

    file { $directories:,
      ensure  => directory,
    }
  }
  elsif ( $logstash2x::ensure == 'absent' ) {
    file { $logstash2x::configdir:
      ensure  => 'absent',
      recurse => true,
      force   => true,
    }
  }
}
