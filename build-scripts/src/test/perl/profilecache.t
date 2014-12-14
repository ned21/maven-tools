use strict;
use warnings;

use Test::More;

use Cwd;

use EDG::WP4::CCM::Element qw(escape);

use Test::Quattor::ProfileCache qw(prepare_profile_cache get_config_for_profile set_profile_cache_options);

# Can't have NoAction here, since no CAF mocking happens
# and otherwise nothing would be written

my $cfg = prepare_profile_cache('profilecache');

isa_ok($cfg, "EDG::WP4::CCM::Configuration", 
            "get_config_for_profile returns a EDG::WP4::CCM::Configuration instance");

is_deeply($cfg->getElement("/")->getTree(), 
            {test => "data"}, 
            "getTree of root element returns correct hashref");

my $cfg2 = get_config_for_profile('profilecache');
is_deeply($cfg, $cfg2, 
          "get_config_for_profile fecthes same configuration object as returned by prepare_profile_cache");

# verify defaults; they shouldn't "just" change
my $currentdir = getcwd();
my $dirs = Test::Quattor::ProfileCache::get_profile_cache_dirs();
is_deeply($dirs, {
    resources => "$currentdir/src/test/resources",
    profiles => "$currentdir/target/test/profiles",
    cache => "$currentdir/target/test/cache",
    }, "Default profile_cache directories");

set_profile_cache_options(resources => 'src/test/resources/myresources');
$dirs = Test::Quattor::ProfileCache::get_profile_cache_dirs();
is($dirs->{resources}, "$currentdir/src/test/resources/myresources", 
    "Set and retrieved custom profile_cache resources dir");

# test rename
is(Test::Quattor::ProfileCache::profile_cache_name("test"), "test", 
    "Profilecache name preserves original behaviour");
is(Test::Quattor::ProfileCache::profile_cache_name("$dirs->{resources}/subtree/test.pan"), escape("subtree/test"), 
    "Profilecache name handles absolute paths");


# test absolute path
my $profile = "$dirs->{resources}/absprofilecache.pan";
ok (-f $profile, "Found profile $profile");
my $abscfg = prepare_profile_cache($profile);

isa_ok($abscfg, "EDG::WP4::CCM::Configuration", 
            "get_config_for_profile returns a EDG::WP4::CCM::Configuration instance for abs profile");

is_deeply($abscfg->getElement("/")->getTree(), 
            {test => "data"}, 
            "getTree of root element returns correct hashref for abs profile");

my $abscfg2 = get_config_for_profile($profile);
is_deeply($abscfg, $abscfg2, 
          "get_config_for_profile fecthes same configuration object as returned by prepare_profile_cache for abs profile");


done_testing();