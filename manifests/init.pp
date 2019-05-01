# Manage Atlassian Bamboo
#
# Refer to the README at the root of this module for documentation
#
class bamboo (
  Pattern[/^\d+\.\d+\.\d+(\.\d+)?$/] $version               = '6.7.1',
  Enum['tar.gz', 'zip']              $extension             = 'tar.gz',
  Boolean                            $manage_installdir     = true,
  Stdlib::Unixpath                   $installdir            = '/usr/local/bamboo',
  Boolean                            $manage_appdir         = true,
  Optional[Stdlib::Unixpath]         $appdir                = undef,
  Stdlib::Unixpath                   $homedir               = '/var/local/bamboo',
  String                             $context_path          = '',
  Stdlib::Port                       $tomcat_port           = 8085,
  Integer                            $max_threads           = 150,
  Integer                            $min_spare_threads     = 25,
  Integer                            $connection_timeout    = 20000,
  Integer                            $accept_count          = 100,
  Optional[Hash]                     $proxy                 = {},
  Boolean                            $manage_user           = true,
  Boolean                            $manage_group          = true,
  Pattern[/^[a-z_][a-z0-9_-]*[$]?$/] $user                  = 'bamboo',
  Pattern[/^[a-z_][a-z0-9_-]*[$]?$/] $group                 = 'bamboo',
  Optional[Integer]                  $uid                   = undef,
  Optional[Integer]                  $gid                   = undef,
  String                             $password              = '*',
  Stdlib::Unixpath                   $shell                 = '/bin/bash',
  Stdlib::Unixpath                   $java_home             = '/usr/lib/jvm/java',
  Pattern[/^\d+(m|g)$/]              $jvm_xms               = '256m',
  Pattern[/^\d+(m|g)$/]              $jvm_xmx               = '1024m',
  Optional[Pattern[/^\d+(m|g)$/]]    $jvm_permgen           = undef,
  String                             $jvm_opts              = '',
  Optional[String]                   $jvm_optional          = '',
  Stdlib::Httpurl                    $download_url          = 'https://www.atlassian.com/software/bamboo/downloads/binary',
  Boolean                            $manage_service        = true,
  Stdlib::Ensure::Service            $service_ensure        = 'running',
  Boolean                            $service_enable        = true,
  Stdlib::Unixpath                   $service_file          = $bamboo::params::service_file,
  Pattern[/^(\w+)\/([\/\.\w\s]+)$/]  $service_template      = $bamboo::params::service_template,
  Integer                            $shutdown_wait         = 20,
  Boolean                            $initconfig_manage     = false,
  Stdlib::Unixpath                   $initconfig_path       = $bamboo::params::initconfig_path,
  Optional[String]                   $initconfig_content    = '',
  Enum['present', 'absent']          $facts_ensure          = 'present',
  Stdlib::Unixpath                   $facter_dir            = $bamboo::params::facter_dir,
  Boolean                            $create_facter_dir     = true,
  String                             $stop_command          = $bamboo::params::stop_command,
  Optional[Integer]                  $umask                 = undef,
  Optional[String]                   $proxy_server          = undef,
  Optional[String]                   $proxy_type            = undef,
  Optional[String]                   $checksum              = undef,
  Optional[Pattern[/^(none|md5|sha1|sha2|sha256|sha384|sha512)$/]] $checksum_type = 'md5',
) inherits bamboo::params {

  if $jvm_permgen {
    if versioncmp($version, '5.10') >= 0 {
      warning('Bamboo >= 5.10 requires Java 1.8, which obsoletes the -XX:MaxPermSize parameter.')
    }
  }

  if $appdir == undef or $appdir == '' {
    $real_appdir = "${installdir}/atlassian-bamboo-${version}"
  } else {
    $real_appdir = $appdir
  }

  if $checksum == undef {
    $checksum_verify = false
  } else {
    $checksum_verify = true
  }

  contain 'bamboo::install'
  contain 'bamboo::facts'
  contain 'bamboo::configure'
  contain 'bamboo::service'

  Class['bamboo::install']
  -> Class['bamboo::facts']
  -> Class['bamboo::configure']
  ~> Class['bamboo::service']

}
