::java -cp C:\Daten\Software\Saxon\Saxon-B\9.1.0.8\saxon9.jar net.sf.saxon.Transform -s:XMI.xml -xsl:XMI2OWL.xsl -o:OWL.owl baseOntologyIRI=http://rdf-vocabulary.ddialliance.org/DDICoreVocabulary compositionName=contains
java -cp C:\Daten\Software\Saxon\Saxon-B\9.1.0.8\saxon9.jar net.sf.saxon.Transform -s:phdd_xmi.xml -xsl:XMI2OWL.xsl -o:phdd.owl baseOntologyIRI=http://rdf-vocabulary.ddialliance.org/phdd compositionName=contains
		
PAUSE transformation successful!