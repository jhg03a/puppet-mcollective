# == Class: mcollective::client
#
# This module manages the MCollective client application
#
# === Parameters
#
# [*etcdir*]
#   Location of mcollective configuration files.
#   Defaults to $mcollective::etcdir which defaults to os-dependent location
#
# [*hosts*]
#   An array of middleware brokers for the client to connect
#   Defaults to $mcollective::hosts
#
# [*collectives*]
#   An array of collectives for the client to subscribe to
#   Defaults to $mcollective::collectives
#
# [*package*]
#   The name of the package to install or remove
#   Defaults to os-dependent value from mcollective::params
#
# [*version*]
#   The version or state of the package
#   Values: latest (default), present, absent, or specific version number
#
# [*unix_group*]
#   The unix group that will be allowed to read the client.cfg file.
#   This is security for the pre-shared-key when PSK is used.
#   Default: wheel
#
# [*logger_type*]
#   Where to send log messages. You usually want the user to see them.
#   Values: console (default), syslog, file
#
# [*log_level*]
#   How verbose should logging be?
#   Values: fatal, error, warn (default), info, debug
#
# [*logfacility*]
#   If logger_type is syslog, which log facility to use? Default: user
#
# [*logfile*]
#   If logger_type is file, what file should the logs be put in?
#   Default is os-dependent, often /var/log/mcollective.log
#
# [*keeplogs*]
#   Any positive value will enable log rotation retaining that many files.
#   A blank or 0 value will disable log rotation.
#   Default: 5
#
# [*max_log_size*]
#    Max size in bytes for log files before rotation happens.
#    Default: 2097152 (2mb)
#
# [*disc_method*]
#    Defines the default discovery method to use
#    Default: mc
#
# [*disc_options*]
#    Defines the default discovery options to use
#    Default: undefined
#
# [*da_threshold*]
#    Defines the threshold used to determine when to use direct addressing
#    Default: 10
#
# [*sshkey_private_key*]
#    A private key used to sign requests with
#    Default: undefined  (only matters if security_provider is sshkey)
#    When undefined, sshkey uses the ssh-agent to find a key
#
# [*sshkey_private_key_content*]
#    Defines the content of the private key file for hiera-eyaml integration
#    Default: undefined
#    When undefined, openssl will be invoked to generate a new private key
#
# [*sshkey_known_hosts*]
#    A known_hosts file
#    Default: undefined  (only matters if security_provider is sshkey)
#    When undefined, sshkey uses /home/$USER/.ssh/known_hosts which is the same as OpenSSH by default
#
# [*sshkey_send_key*]
#    Send the specified public key along with the request for dynamic key management
#    Default: undefined  (only matters if security_provider is sshkey)
#
# === Variables
#
# This class makes use of these variables from base mcollective class
#
# [*client_user*]
#   The username clients will use to authenticate. Default: client
#
# [*client_password*]
#   Required: The password clients will use to authenticate
#
# [*connector*]
#   Which middleware connector to use. Values: 'activemq' (default) or 'rabbitmq'
#
# [*port*]
#   Which port to connect to. Default: 61613
#
# [*connector_ssl*]
#   Use SSL service? Values: false (default), true
#
# [*connector_ssl_type*]
#   Which type of SSL encryption should be used? (ActiveMQ only) Values: anonymous (default), trusted
#
# [*security_provider*]
#   Values: psk (default), sshkey, ssl, aes_security
#
# [*psk_key*]
#   Pre-shared key if provider is psk
#
# [*psk_callertype*]
#   Valid to put in the 'caller' field of each request.
#   Values: uid (default), gid, user, group, identity
#
# [*sshkey_publickey_dir*]
#    Defines a directory to store received sshkey-based keys
#    Default: undefined  (only matters if security_provider is sshkey)
#
# [*sshkey_learn_public_keys*]
#    Allows the sshkey plugin to write out sent keys to [*sshkey_publickey_dir*]
#    Default: Do not send  (only matters if security_provider is sshkey)
#    Values: true,false (default)
#
# [*sshkey_overwrite_stored_keys*]
#    In the event of a key mismatch, overwrite stored key data
#    Default: Do not overwrite  (only matters if security_provider is sshkey)
#    Values: true, false (default)
#
# [*trusted_ssl_server_cert*]
#   The path to your trusted server certificate. (Only used with trusted connector_ssl_type)
#   Default: Re-use your puppet CA infrastructure
#
# [*trusted_ssl_server_key*]
#   The path to your private key used with the trusted server certificate. (Only used with trusted connector_ssl_type)
#   Default: Re-use your puppet CA infrastructure
#
# [*trusted_ssl_ca_cert*]
#   The path to your trusted certificate authority certificate. (Only used with trusted connector_ssl_type)
#   Default: Re-use your puppet CA infrastructure
#
# === Examples
#
#  class { 'mcollective::client':
#    hosts       => ['activemq.example.net'],
#    collectives => ['mcollective'],
#  }
#
# Hiera
#   mcollective::hosts :
#     - 'activemq.example.net'
#   mcollective::collectives :
#     - 'mcollective'
#
class mcollective::client(
  # This value can be overridden in Hiera or through class parameters
  $unix_group                   = 'wheel',
  $etcdir                       = $mcollective::etcdir,
  $hosts                        = $mcollective::hosts,
  $collectives                  = $mcollective::collectives,
  $package                      = $mcollective::params::client_package_name,
  $trusted_ssl_server_cert      = $mcollective::trusted_ssl_server_cert,
  $trusted_ssl_server_key       = $mcollective::trusted_ssl_server_key,
  $trusted_ssl_ca_cert          = $mcollective::trusted_ssl_ca_cert,

  # Package update?
  $version            = 'latest',

  # Logging
  $logfile      = $mcollective::params::logfile,
  $logger_type  = 'console',
  $log_level    = 'warn',
  $logfacility  = 'user',
  $keeplogs     = '5',
  $max_log_size = '2097152',
  $disc_method  = 'mc',
  $disc_options = undef,
  $da_threshold = '10',
  
  # Authentication
  $sshkey_private_key           = undef,
  $sshkey_private_key_content   = undef,
  $sshkey_known_hosts           = undef,
  $sshkey_send_key              = undef,
  $sshkey_publickey_dir         = $mcollective::sshkey_publickey_dir,
  $sshkey_learn_public_keys     = $mcollective::sshkey_learn_public_keys,
  $sshkey_overwrite_stored_keys = $mcollective::sshkey_overwrite_stored_keys,
)
inherits mcollective {

  validate_array( $hosts )
  validate_array( $collectives )
  validate_re( $version, '^present$|^latest$|^[._0-9a-zA-Z:-]+$' )
  validate_re( $unix_group, '^[._0-9a-zA-Z-]+$' )
  validate_re( $da_threshold, '^[0-9]+$' )

  # Validate that client username and password were supplied
  validate_re( $client_user, '^.{5}', 'Please provide a client username' )
  validate_re( $client_password, '^.{12}', 'Please provide at last twelve characters in client password' )

  package { $package:
    ensure  => $version,
  }

  file { "${etcdir}/client.cfg":
    ensure  => file,
    owner   => root,
    group   => $unix_group,
    mode    => '0440',
    content => template( 'mcollective/client.cfg.erb' ),
    require => Package[ $package ],
  }
  
  # Create a shared/default private key
  if( $sshkey_private_key_content ){
    # If you supplied a path, overwrite it
    if( $sshkey_private_key ){
      file{ $sshkey_private_key:
        ensure  => file,
        group   => $unix_group,
        mode    => '0440',
        content => $sshkey_private_key_content,
      }
    }
    else {
      # Create a default location
      $sshkey_private_key = "${etcdir}/sshkey/sshkey_private_key.pem"
      
      file {"${etcdir}/sshkey":
        ensure  =>  'directory',
        group   =>  $unix_group,
        mode    =>  '0440',
      }
      
      file {$sshkey_private_key:
        ensure  =>  file,
        group   =>  $unix_group,
        mode    =>  '0440',
        content =>  $sshkey_private_key_content,
      }
    }
  }

  # Handle all per-user configurations
  $userdefaults  = { group => 'wheel' }
  $userlist  = hiera_hash( 'mcollective::userconfigs', false )
  if is_hash( $userlist ) {
    create_resources( mcollective::userconfig, $userlist, $userdefaults )
  }

  # Load in all the appropriate mcollective client plugins
  $defaults  = { version => 'present' }
  $clients  = hiera_hash( 'mcollective::plugin::clients', false )
  if is_hash( $clients ) {
    create_resources( mcollective::plugin::client, $clients, $defaults )
  }

  # Management of SSL keys
  if( $mcollective::security_provider == 'ssl' ) {
    # Ensure the package is installed before we create this directory
    Package[$package] -> File["${etcdir}/ssl"]

    # copy the server public keys to all servers
    realize File["${etcdir}/ssl/server/public.pem"]
  }
}
