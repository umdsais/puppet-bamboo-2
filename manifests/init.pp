# Class: bamboo
#
# This module manages Atlassian Bamboo
#
# Refer to the README at the root of this module for documentation
#
class bamboo (
  $version            = '6.7.1',
  $extension          = 'tar.gz',
  $manage_installdir  = true,
  $installdir         = '/usr/local/bamboo',
  $manage_appdir      = true,
  $appdir             = undef,
  $homedir            = '/var/local/bamboo',
  $context_path       = '',
  $tomcat_port        = 8085,
  $max_threads        = 150,
  $min_spare_threads  = 25,
  $connection_timeout = 20000,
  $accept_count       = 100,
  $proxy              = {},
  $manage_user        = true,
  $manage_group       = true,
  $user               = 'bamboo',
  $group              = 'bamboo',
  $uid                = undef,
  $gid                = undef,
  $password           = '*',
  $shell              = '/bin/bash',
  $java_home          = '/usr/lib/jvm/java',
  $jvm_xms            = '256m',
  $jvm_xmx            = '1024m',
  $jvm_permgen        = undef,
  $jvm_opts           = '',
  $jvm_optional       = '',
  $download_url       = 'https://www.atlassian.com/software/bamboo/downloads/binary',
  $manage_service     = true,
  $service_ensure     = 'running',
  $service_enable     = true,
  $service_file       = $bamboo::params::service_file,
  $service_template   = $bamboo::params::service_template,
  $shutdown_wait      = 20,
  $initconfig_manage  = false,
  $initconfig_path    = $bamboo::params::initconfig_path,
  $initconfig_content = '',
  $facts_ensure       = 'present',
  $facter_dir         = $bamboo::params::facter_dir,
  $create_facter_dir  = true,
  $stop_command       = $bamboo::params::stop_command,
  $umask              = undef,
  $proxy_server       = undef,
) inherits bamboo::params {

  validate_re($version, ['^\d+\.\d+\.\d+$', '^\d+\.\d+\.\d+\.\d+$'])
  validate_re($extension, '^(tar\.gz|\.zip)$')
  validate_absolute_path($installdir)
  validate_absolute_path($homedir)

  if !empty($context_path) { validate_string($context_path) }

  validate_integer($tomcat_port)
  validate_integer($max_threads)
  validate_integer($min_spare_threads)
  validate_integer($connection_timeout)
  validate_integer($accept_count)
  validate_hash($proxy)
  validate_bool($manage_user)
  validate_bool($manage_group)

  validate_re($user, '^[a-z_][a-z0-9_-]*[$]?$')
  validate_re($group, '^[a-z_][a-z0-9_-]*[$]?$')

  if $uid { validate_integer($uid) }
  if $gid { validate_integer($gid) }

  validate_string($password)
  validate_absolute_path($shell)
  validate_absolute_path($java_home)
  validate_re($jvm_xms, '\d+(m|g)$')
  validate_re($jvm_xmx, '\d+(m|g)$')

  if $jvm_permgen {
    if versioncmp($version, '5.10') >= 0 {
      warning('Bamboo >= 5.10 requires Java 1.8, which obsoletes the -XX:MaxPermSize parameter.')
    }
    validate_re($jvm_permgen, '\d+(m|g)$')
  }

  if !empty($jvm_opts) { validate_string($jvm_opts) }
  if !empty($jvm_optional) { validate_string($jvm_optional) }

  validate_re($download_url, '^((https?|ftps?):\/\/)?([\da-z\.-]+)\.?([a-z\.]{2,6})([\/\w \.-]*)*\/?$')
  validate_bool($manage_service)
  validate_re($service_ensure, '(running|stopped)')
  validate_bool($service_enable)
  validate_absolute_path($service_file)

  validate_re($service_template, '^(\w+)\/([\/\.\w\s]+)$',
    'service_template should be modulename/path/to/template.erb'
  )

  validate_integer($shutdown_wait)

  if $appdir == undef or $appdir == '' {
    $real_appdir = "${installdir}/atlassian-bamboo-${version}"
  }
  else {
    validate_absolute_path($appdir)
    $real_appdir = $appdir
  }

  validate_bool($initconfig_manage)
  validate_absolute_path($initconfig_path)
  if !empty($initconfig_content) { validate_string($initconfig_content) }

  validate_re($facts_ensure, '(present|absent)')
  validate_absolute_path($facter_dir)
  validate_bool($create_facter_dir)
  validate_string($stop_command)

  anchor { 'bamboo::start': }
    -> class { 'bamboo::install': }
    -> class { 'bamboo::facts': }
    -> class { 'bamboo::configure': }
    ~> class { 'bamboo::service': }
    -> anchor { 'bamboo::end': }

}
