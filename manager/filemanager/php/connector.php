<?php

error_reporting(0); // Set E_ALL for debuging

include_once dirname(__FILE__).DIRECTORY_SEPARATOR.'elFinderConnector.class.php';
include_once dirname(__FILE__).DIRECTORY_SEPARATOR.'elFinder.class.php';
include_once dirname(__FILE__).DIRECTORY_SEPARATOR.'elFinderVolumeDriver.class.php';
include_once dirname(__FILE__).DIRECTORY_SEPARATOR.'elFinderVolumeLocalFileSystem.class.php';
// Required for MySQL storage connector
// include_once dirname(__FILE__).DIRECTORY_SEPARATOR.'elFinderVolumeMySQL.class.php';
// Required for FTP connector support
// include_once dirname(__FILE__).DIRECTORY_SEPARATOR.'elFinderVolumeFTP.class.php';


/**
 * Simple function to demonstrate how to control file access using "accessControl" callback.
 * This method will disable accessing files/folders starting from  '.' (dot)
 *
 * @param  string  $attr  attribute name (read|write|locked|hidden)
 * @param  string  $path  file path relative to volume root directory started with directory separator
 * @return bool|null
 **/
function access($attr, $path, $data, $volume) {
	return strpos(basename($path), '.') === 0       // if file/folder begins with '.' (dot)
		? !($attr == 'read' || $attr == 'write')    // set read+write to false, other (locked+hidden) set to true
		:  null;                                    // else elFinder decide it itself
}

$opts = array(
	// 'debug' => true,
	'roots' => array(
		array(
			'driver'        => 'LocalFileSystem',   // driver for accessing file system (REQUIRED)
			'path'          => '../../../../sandbox.hubutu.com/',         // path to files (REQUIRED) ../../../theme/
			'URL'           => 'http://hubutu.olivecommerce.com/', // URL to files (REQUIRED) dirname($_SERVER['PHP_SELF']) . '/../files/'
			'alias'      => 'Home',
			'attributes' => array(
				array( // hide readmes
                    'pattern' => '/core/',
                    'read' => false,
                    'write' => false,
                    'hidden' => false,
                    'locked' => true
                ),
				array( // hide readmes
                    'pattern' => '/icecat/',
                    'read' => false,
                    'write' => false,
                    'hidden' => false,
                    'locked' => true
                ),
				array( // hide readmes
                    'pattern' => '/manager/',
                    'read' => false,
                    'write' => false,
                    'hidden' => false,
                    'locked' => true
                ),
				array( // hide readmes
                    'pattern' => '/admin/',
                    'read' => false,
                    'write' => false,
                    'hidden' => true,
                    'locked' => false
                ),
				array( // hide readmes
                    'pattern' => '/util/',
                    'read' => false,
                    'write' => false,
                    'hidden' => false,
                    'locked' => true
                ),
                array( // hide readmes
                    'pattern' => '/\.phtml$/',
                    'read' => false,
                    'write' => false,
                    'hidden' => false,
                    'locked' => true
                ),
				array( // hide readmes
                    'pattern' => '/\.php$/',
                    'read' => false,
                    'write' => false,
                    'hidden' => false,
                    'locked' => true
                ),
				array( // hide readmes
                    'pattern' => '/\.ini$/',
                    'read' => false,
                    'write' => false,
                    'hidden' => false,
                    'locked' => true
                ),
				array( // hide readmes
                    'pattern' => '/\.asa$/',
                    'read' => false,
                    'write' => false,
                    'hidden' => true,
                    'locked' => true
                ),
				array( // hide readmes
                    'pattern' => '/\.asp$/',
                    'read' => false,
                    'write' => false,
                    'hidden' => true,
                    'locked' => true
                ),
                array( // restrict access to png files
                    'pattern' => '/\.png$/',
                    'write' => false,
                    'locked' => true
                )
            ),
			'accessControl' => 'access'             // disable and hide dot starting files (OPTIONAL)
		)
	)
);

// run elFinder
$connector = new elFinderConnector(new elFinder($opts));
$connector->run();

