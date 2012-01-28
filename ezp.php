#!/usr/bin/env php
<?php
/**
 * File containing the ezp.php script.
 *
 * @copyright Copyright (C) 1999-2011 eZ Systems AS. All rights reserved.
 * @license http://www.gnu.org/licenses/gpl-2.0.txt GNU General Public License v2
 * @version //autogentag//
 */

/**
 * This script is the root script to eZ Publish bin/php scripts.
 *
 * Unlike individual scripts, it offers bash completion through the /etc/bash_completion.d/ezp script.
 *
 * Return values:
 * - 0: OK
 * - 1: unknown command
 * - 2: unknown script
 *
 * Arguments:
 * - _scripts: returns a space separated list of available scripts
 * - _args <script>: returns the space separated list of available arguments for <script>
 */

// these environnement variables are set by the completion shell script
$ezpCompDir = getenv( 'EZPCOMP_EZ_DIR' );
$ezpCompIseZDir = getenv( 'EZPCOMP_IS_EZ_DIR' );
$ezpCompPwd = getenv( 'EZPCOMP_PWD' );

// switch the working directory based on what the completion shell script has
if ( $ezpCompIseZDir == 1 && $ezpCompPwd == getcwd() )
{
    chdir( $ezpCompDir );
}

if ( !file_exists( "lib/version.php" ) )
{
    echo "This script can only be executed from inside an eZ Publish directory\n";
    exit( 1 );
}

require 'autoload.php';

$input = new ezcConsoleInput();
try {
    $input->process();
} catch( ezcConsoleOptionException $e )
{
    die( $e->getMessage() );
}

$arguments = $input->getArguments();
if ( count( $arguments ) === 0 )
{
    return 1;
}

switch( $arguments[0] )
{
    // scripts list
    case '_scripts':
        complete( getScripts() );
        break;

    // arguments list for a script
    case '_args':
        if ( !isset( $arguments[1] ) )
            return 2;
        $script = getScript( $arguments[1] );
        if ( $script == false )
            return 2;

        $arguments = getArguments( $script );
        if ( $arguments == false )
            return 2;

        complete( $arguments );
        break;

    case '_siteaccess_list':
        $siteaccessList = eZINI::instance()->variable( 'SiteAccessSettings', 'AvailableSiteAccessList' );
        complete( $siteaccessList );
        break;

    case '_ezcache_tags':
        complete( eZCache::fetchTagList() );
        break;

    case '_ezcache_ids':
        complete( eZCache::fetchIDList() );
        break;

    // execute the script
    default:
        $script = getScript( array_shift( $arguments ) );
        $arguments = implode( ' ', $arguments );
	echo "Running $script $arguments\n";
        passthru( "$script $arguments" );
}

/**
 * Formats and output a words list for completion
 * @param array $words
 */
function complete( array $words )
{
    echo implode( "\n", $words );
}

/**
 * Returns the list of available scripts, without the ez/ezp prefix and without the .php extension
 *
 * Spaces are added at the of each script name for better completion
 *
 * @return array
 */
function getScripts()
{
    $iterator = new GlobIterator( 'bin/php/*.php' );
    foreach( $iterator as $key => $script )
    {
        if ( !$script->isFile() )
            continue;

        // $scriptName = str_replace( '.php', '', $script->getFilename() );
        $scriptName = preg_replace( '#(ezp?)?(.*)\.php#', '$2', $script->getFilename() );
        $scripts[] = "$scriptName ";
    }
    $scripts[] = 'runcronjobs ';
    return $scripts;
}

/**
 * Returns the path to a script based on the stripped name (as returned by getScripts)
 * @return string
 */
function getScript( $script )
{
    if ( $script == 'runcronjobs' )
    {
        return './runcronjobs.php';
    }

    $candidatePaths = array( 'bin/php/ez', 'bin/php/ezp', 'bin/php/' );
    foreach( $candidatePaths as $candidatePath )
    {
        $path = "{$candidatePath}{$script}.php";
        if ( file_exists( $path ) )
            return $path;
    }
    return false;
}

/**
 * Returns the arguments list for $script
 *
 * Spaces are added at the of each argument except if it ends with an = sign, for better completion
 *
 * @param string $script (root) relative path to the script
 * @return array List of arguments, dashes included
 */
function getArguments( $script )
{
    $helpText = `php $script --help`;

    // command line example, for non option arguments
    $eZScriptPattern = '/Usage: [^ ]+ \[OPTION\]\.\.\.(?: \[([a-z0-9]+)\])?/i';
    if ( preg_match( $eZScriptPattern, $helpText, $matches ) )
        print_r( $matches );

    // arguments
    $eZScriptPattern = '/^  (?:(-[-_a-z0-9+]),)?(--[-_a-z0-9]+=?)(?:VALUE)?/ms';
    $ezcPattern = '/^(?:(-[-_a-z0-9+]) \/ )?(--[-_a-z0-9]+=?)(?:VALUE)?/ms';

    if ( !preg_match_all( $eZScriptPattern, $helpText, $options, PREG_SET_ORDER ) )
        if ( !preg_match_all( $ezcPattern, $helpText, $options, PREG_SET_ORDER ) )
            return false;

    $result = array();
    foreach( $options as $option )
    {
        if ( !empty( $option[1] ) )
        {
            if ( substr( $option[1], -1 ) !=  '=' )
                $option[1] .= ' ';
            $result[] = $option[1];
        }

        if ( !empty( $option[2] ) )
        {
            if ( $option[2] == '--siteaccess' )
                $option[2] .= '=';
            if ( substr( $option[2], -1 ) !=  '=' )
                $option[2] .= ' ';
            $result[] = $option[2];
        }
    }

    return $result;
}
?>
