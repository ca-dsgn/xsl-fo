<?php

	$xml = simplexml_load_file("data2.xml");

	$xp = new XSLTProcessor();

	$xsl = new DomDocument('1.0','utf-8');
	$xsl->load('xml2pdf2.xsl');
	
	$xp->importStylesheet($xsl);
	
	// create a DOM document and load the XML data
	$xml_doc = new DomDocument('1.0','utf-8');
	
	if (!$xml_doc->loadXML($xml->asXML())) {
		
		throw new Exception('HTML Loading failed: '.E_USER_ERROR);
	}
	
	if ($output = $xp->transformToXML($xml_doc)) {
		
		print $output;
	}
	
	include("parts/footer.php");
	
?>