<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"  
    xmlns:uml="http://schema.omg.org/spec/UML/2.1" 
    xmlns:xmi="http://schema.omg.org/spec/XMI/2.1"
    xmlns:ddifunc="ddi:functions"
    exclude-result-prefixes="xs"
    version="2.0">

    <!-- imports -->
    <xsl:import href="support.xsl"/>

    <!-- base ontology IRI -->
    <xsl:param name="baseOntologyIRI">http://rdf-vocabulary.ddialliance.org/DDICoreVocabulary</xsl:param>

    <!-- default composition name -->
    <xsl:param name="compositionName">contains</xsl:param>

    <!-- ............... -->
    <!-- XMI root element -->
    <xsl:template match="xmi:XMI">
        
        <xsl:call-template name="rdfDocumentHeader"/>
        <xsl:call-template name="ontologyMetadata"/>
        
        <!-- UML model -->
        <xsl:apply-templates select="uml:Model[@xmi:type='uml:Model']" mode="model"/>
        
        <xsl:call-template name="rdfDocumentEnd"/>
        
    </xsl:template>
    <!-- ..... -->
    
    <!-- ............... -->
    <!-- UML model -->
    <xsl:template match="uml:Model" mode="model">
        
        <!-- UML package -->
        <xsl:apply-templates select="packagedElement[@xmi:type='uml:Package']" mode="package"/>
        
    </xsl:template>
    <!-- ..... -->
    
    <!-- ............... -->
    <!-- UML package -->
    <xsl:template match="packagedElement" mode="package">
        
        <!-- UML package -->
        <xsl:apply-templates select="packagedElement[@xmi:type='uml:Package']" mode="package"/>
        
        <!-- UML class -->
        <xsl:apply-templates select="packagedElement[@xmi:type='uml:Class']" mode="class">
            <xsl:with-param name="packageName" select="ddifunc:rename(./@name, 'package')"/>
        </xsl:apply-templates>
        
    </xsl:template>
    <!-- ..... -->
    
    <!-- ............... -->
    <!-- UML class -->
    <xsl:template match="packagedElement" mode="class">
        
        <!-- package name -->
        <xsl:param name="packageName"/>
        
        <!-- class name -->
        <xsl:variable name="className">
            <xsl:value-of select="ddifunc:rename(./@name, 'class')"/>
        </xsl:variable>
        
        <!-- class IRI -->
        <xsl:variable name="classIRI">
            <xsl:value-of select="$baseOntologyIRI"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="$packageName"/>
            <xsl:text>#</xsl:text>
            <xsl:value-of select="$className"/>
        </xsl:variable>
        
        <!-- label -->
        <xsl:variable name="label">
            <xsl:value-of select="ddifunc:uncamelize($className)"/>
            <!-- abstract class -->
            <xsl:if test="./@isAbstract = 'true'">
                <xsl:text> (Abstract)</xsl:text>
            </xsl:if>
        </xsl:variable>
        
        <!-- rdfs:isDefinedBy -->
        <xsl:variable name="isDefinedBy">
            <xsl:value-of select="$baseOntologyIRI"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="$packageName"/>
        </xsl:variable>
        
        <xsl:text disable-output-escaping="yes"><![CDATA[	
    <!-- +++++++++++++++ -->
    <!-- ]]></xsl:text><xsl:value-of select="$classIRI"/><xsl:text disable-output-escaping="yes"><![CDATA[ -->
            
    <!-- UML class -->
    <owl:Class rdf:about="]]></xsl:text><xsl:value-of select="$classIRI"/><xsl:text disable-output-escaping="yes"><![CDATA[">
        <rdf:type rdf:resource="http://www.w3.org/2000/01/rdf-schema#Class"/>
        <rdfs:isDefinedBy rdf:resource="]]></xsl:text><xsl:value-of select="$isDefinedBy"/><xsl:text disable-output-escaping="yes"><![CDATA["/>
        <rdfs:label xml:lang="en">]]></xsl:text><xsl:value-of select="$label"/><xsl:text disable-output-escaping="yes"><![CDATA[</rdfs:label>]]></xsl:text>
        
        <!-- UML generalization -->
        <xsl:apply-templates select="generalization[@xmi:type='uml:Generalization']" mode="generalization"/>
        
        <xsl:text disable-output-escaping="yes"><![CDATA[
    </owl:Class>
]]>     </xsl:text>
        
        <!-- UML attribute -->
        <xsl:apply-templates select="ownedAttribute[@xmi:type='uml:Property'][@name]" mode="attribute">
            <xsl:with-param name="packageName" select="$packageName"/>
            <xsl:with-param name="domainClassIRI" select="$classIRI"/>
        </xsl:apply-templates>
        
        <!-- UML association or composition -->
        <xsl:apply-templates select="ownedAttribute[@xmi:type='uml:Property'][@association]" mode="association">
            <xsl:with-param name="domainClassPackageName" select="$packageName"/>
            <xsl:with-param name="domainClassIRI" select="$classIRI"/>
        </xsl:apply-templates>
        
        <!-- source cardinality -->
        <xsl:apply-templates select="ownedAttribute[@xmi:type='uml:Property'][@association]" mode="sourceCardinality"/>
        
        <!-- target cardinality -->
        <xsl:apply-templates select="ownedAttribute[@xmi:type='uml:Property'][@association]" mode="targetCardinality"/>
        
        <xsl:text disable-output-escaping="yes"><![CDATA[	
    <!-- +++++ -->]]>
        </xsl:text>    
        
    </xsl:template>
    <!-- ..... -->
    
    <!-- ............... -->
    <!-- UML generalization -->
    <xsl:template match="generalization" mode="generalization">
        
        <!-- super class ID -->
        <xsl:variable name="superClassID">
            <xsl:value-of select="./@general"/>
        </xsl:variable>
        
        <!-- super class name --> 
        <xsl:variable name="superClassName">
            <xsl:value-of select="ddifunc:rename(//packagedElement[@xmi:type='uml:Class'][@xmi:id=$superClassID]/@name, 'class')"/>
        </xsl:variable>
        
        <!-- super class package name -->
        <xsl:variable name="superClassPackageName">
            <xsl:value-of select="ddifunc:rename(//packagedElement[@xmi:type='uml:Class'][@xmi:id=$superClassID]/..[@xmi:type='uml:Package']/@name, 'package')"/>
        </xsl:variable>
        
        <!-- super class IRI -->
        <xsl:variable name="superClassIRI">
            <xsl:value-of select="$baseOntologyIRI"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="$superClassPackageName"/>
            <xsl:text>#</xsl:text>
            <xsl:value-of select="$superClassName"/>
        </xsl:variable>
        
        <xsl:text disable-output-escaping="yes"><![CDATA[
        <rdfs:subClassOf rdf:resource="]]></xsl:text><xsl:value-of select="$superClassIRI"/><xsl:text disable-output-escaping="yes"><![CDATA["/>]]>   </xsl:text>
        
    </xsl:template>
    <!-- ..... -->
    
    <!-- ............... -->
    <!-- UML attribute -->
    <xsl:template match="ownedAttribute" mode="attribute">
        
        <!-- package name -->
        <xsl:param name="packageName"/>
        
        <!-- domain class IRI -->
        <xsl:param name="domainClassIRI"/>
        
        <!-- datatype property name --> 
        <xsl:variable name="datatypePropertyName">
            <xsl:value-of select="ddifunc:rename(./@name, 'property')"/>
        </xsl:variable>
        
        <!-- datatype property IRI -->
        <xsl:variable name="datatypePropertyIRI">
            <xsl:value-of select="$baseOntologyIRI"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="$packageName"/>
            <xsl:text>#</xsl:text>
            <xsl:value-of select="$datatypePropertyName"/>
        </xsl:variable>
        
        <!-- range class name -->
        <xsl:variable name="rangeClassName">
            <xsl:value-of select="ddifunc:rename(./type/@xmi:idref, 'class')"/>
        </xsl:variable>
        
        <!-- label -->
        <xsl:variable name="label">
            <xsl:value-of select="ddifunc:uncamelize($datatypePropertyName)"/>
        </xsl:variable>
        
        <!-- rdfs:isDefinedBy -->
        <xsl:variable name="isDefinedBy">
            <xsl:value-of select="$baseOntologyIRI"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="$packageName"/>
        </xsl:variable>
        
        <xsl:text disable-output-escaping="yes"><![CDATA[	
    <!-- UML attribute -->
    <owl:DatatypeProperty rdf:about="]]></xsl:text><xsl:value-of select="$datatypePropertyIRI"/><xsl:text disable-output-escaping="yes"><![CDATA[">
        <rdf:type rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#Property"/>
        <rdfs:isDefinedBy rdf:resource="]]></xsl:text><xsl:value-of select="$isDefinedBy"/><xsl:text disable-output-escaping="yes"><![CDATA["/>
        <rdfs:label xml:lang="en">]]></xsl:text><xsl:value-of select="$label"/><xsl:text disable-output-escaping="yes"><![CDATA[</rdfs:label>
        <rdfs:domain rdf:resource="]]></xsl:text><xsl:value-of select="$domainClassIRI"/><xsl:text disable-output-escaping="yes"><![CDATA["/>
        <rdfs:range rdf:resource="#]]></xsl:text><xsl:value-of select="$rangeClassName"/><xsl:text disable-output-escaping="yes"><![CDATA["/>
    </owl:DatatypeProperty>
]]>     </xsl:text>
        
    </xsl:template>
    <!-- ..... -->
    
    <!-- ............... -->
    <!-- UML association or composition -->
    <xsl:template match="ownedAttribute" mode="association">
        
        <!-- domain class package name -->
        <xsl:param name="domainClassPackageName"/>
        
        <!-- domain class IRI -->
        <xsl:param name="domainClassIRI"/>
        
        <!-- ............... -->
        <!-- object property IRI -->
        
            <!-- association ID -->
            <xsl:variable name="associationID">
                <xsl:value-of select="./@association"/>
            </xsl:variable>
        
            <!-- objectProperty name -->
            <xsl:variable name="objectPropertyName">
                <xsl:choose>
                    <xsl:when test="//packagedElement[@xmi:type='uml:Association'][@xmi:id=$associationID]/@name">
                        <xsl:value-of select="ddifunc:rename(//packagedElement[@xmi:type='uml:Association'][@xmi:id=$associationID]/@name, 'property')"/>
                    </xsl:when>
                    <xsl:otherwise>
                       <xsl:value-of select="$compositionName"></xsl:value-of>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <!-- object property IRI -->
            <xsl:variable name="objectPropertyIRI">
                <xsl:value-of select="$baseOntologyIRI"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="$domainClassPackageName"/>
                <xsl:text>#</xsl:text>
                <xsl:value-of select="$objectPropertyName"/>
            </xsl:variable>
        
        <!-- ..... -->
        
        <!-- ............... -->
        <!-- range class IRI -->
        
            <!-- range class ID -->
            <xsl:variable name="rangeClassID">
                <xsl:value-of select="./type/@xmi:idref"/>
            </xsl:variable>
            
            <!-- range class name -->
            <xsl:variable name="rangeClassName">
                <xsl:value-of select="ddifunc:rename(//packagedElement[@xmi:type='uml:Class'][@xmi:id=$rangeClassID]/@name, 'class')"/>
            </xsl:variable>
            
            <!-- range class package name -->
            <xsl:variable name="rangeClassPackageName">
                <xsl:value-of select="ddifunc:rename(//packagedElement[@xmi:type='uml:Class'][@xmi:id=$rangeClassID]/..[@xmi:type='uml:Package']/@name, 'package')"/>
            </xsl:variable>
            
            <!-- range class IRI -->
            <xsl:variable name="rangeClassIRI">
                <xsl:value-of select="$baseOntologyIRI"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="$rangeClassPackageName"/>
                <xsl:text>#</xsl:text>
                <xsl:value-of select="$rangeClassName"/>
            </xsl:variable>
        
        <!-- ..... -->
        
        <!-- label -->
        <xsl:variable name="label">
            <xsl:value-of select="ddifunc:uncamelize($objectPropertyName)"/>
        </xsl:variable>
        
        <!-- rdfs:isDefinedBy -->
        <xsl:variable name="isDefinedBy">
            <xsl:value-of select="$baseOntologyIRI"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="$domainClassPackageName"/>
        </xsl:variable>
        
        <xsl:text disable-output-escaping="yes"><![CDATA[
    <!-- UML association or composition -->
    <owl:ObjectProperty rdf:about="]]></xsl:text><xsl:value-of select="$objectPropertyIRI"/><xsl:text disable-output-escaping="yes"><![CDATA[">
        <rdf:type rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#Property"/>
        <rdfs:isDefinedBy rdf:resource="]]></xsl:text><xsl:value-of select="$isDefinedBy"/><xsl:text disable-output-escaping="yes"><![CDATA["/>
        <rdfs:label xml:lang="en">]]></xsl:text><xsl:value-of select="$label"/><xsl:text disable-output-escaping="yes"><![CDATA[</rdfs:label>
        <rdfs:domain rdf:resource="]]></xsl:text><xsl:value-of select="$domainClassIRI"/><xsl:text disable-output-escaping="yes"><![CDATA["/>
        <rdfs:range rdf:resource="]]></xsl:text><xsl:value-of select="$rangeClassIRI"/><xsl:text disable-output-escaping="yes"><![CDATA["/>
    </owl:ObjectProperty>
]]>     </xsl:text>
        
    </xsl:template>
    <!-- ..... -->
    
    <!-- ............... -->
    <!-- source cardinality -->
    <xsl:template match="ownedAttribute" mode="sourceCardinality">
        
        <!-- association ID -->
        <xsl:variable name="associationID">
            <xsl:value-of select="./@association"/>
        </xsl:variable>
        
        <!-- source cardinality only if either min or max cardinalities exist for specific association -->
        <xsl:if test="(//packagedElement[@xmi:type='uml:Association'][@xmi:id=$associationID]/ownedEnd/lowerValue or
                       //packagedElement[@xmi:type='uml:Association'][@xmi:id=$associationID]/ownedEnd/upperValue) and
                      (//packagedElement[@xmi:type='uml:Association'][@xmi:id=$associationID]/ownedEnd/lowerValue/@value!= '0' or
                       //packagedElement[@xmi:type='uml:Association'][@xmi:id=$associationID]/ownedEnd/upperValue/@value != '-1')">
            
            <!-- ............... -->
            <!-- source class IRI -->
            
            <!-- source class ID -->
            <xsl:variable name="sourceClassID">
                <xsl:value-of select="//packagedElement[@xmi:type='uml:Association'][@xmi:id=$associationID]/ownedEnd/type/@xmi:idref"/>
            </xsl:variable>
            
            <!-- source class name -->
            <xsl:variable name="sourceClassName">
                <xsl:value-of select="ddifunc:rename(//packagedElement[@xmi:type='uml:Class'][@xmi:id=$sourceClassID]/@name, 'class')"/>
            </xsl:variable>
            
            <!-- source class package name -->
            <xsl:variable name="sourceClassPackageName">
                <xsl:value-of select="ddifunc:rename(//packagedElement[@xmi:type='uml:Class'][@xmi:id=$sourceClassID]/..[@xmi:type='uml:Package']/@name, 'package')"/>
            </xsl:variable>
            
            <!-- source class IRI -->
            <xsl:variable name="sourceClassIRI">
                <xsl:value-of select="$baseOntologyIRI"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="$sourceClassPackageName"/>
                <xsl:text>#</xsl:text>
                <xsl:value-of select="$sourceClassName"/>
            </xsl:variable>
            
            <!-- ..... -->
            
            <!-- ............... -->
            <!-- target class IRI -->
            
            <!-- target class ID -->
            <xsl:variable name="targetClassID">
                <xsl:value-of select="./type/@xmi:idref"/>
            </xsl:variable>
            
            <!-- target class name -->
            <xsl:variable name="targetClassName">
                <xsl:value-of select="ddifunc:rename(//packagedElement[@xmi:type='uml:Class'][@xmi:id=$targetClassID]/@name, 'class')"/>
            </xsl:variable>
            
            <!-- target class package name -->
            <xsl:variable name="targetClassPackageName">
                <xsl:value-of select="ddifunc:rename(//packagedElement[@xmi:type='uml:Class'][@xmi:id=$targetClassID]/..[@xmi:type='uml:Package']/@name, 'package')"/>
            </xsl:variable>
            
            <!-- target class IRI -->
            <xsl:variable name="targetClassIRI">
                <xsl:value-of select="$baseOntologyIRI"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="$targetClassPackageName"/>
                <xsl:text>#</xsl:text>
                <xsl:value-of select="$targetClassName"/>
            </xsl:variable>
            
            <!-- ..... -->
            
            <!-- ............... -->
            <!-- object property IRI -->
            
            <!-- object property name -->
            <xsl:variable name="objectPropertyName">
                <xsl:choose>
                    <xsl:when test="//packagedElement[@xmi:type='uml:Association'][@xmi:id=$associationID]/@name">
                        <xsl:value-of select="ddifunc:rename(//packagedElement[@xmi:type='uml:Association'][@xmi:id=$associationID]/@name, 'property')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$compositionName"></xsl:value-of>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <!-- object property IRI -->
            <xsl:variable name="objectPropertyIRI">
                <xsl:value-of select="$baseOntologyIRI"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="$sourceClassPackageName"/>
                <xsl:text>#</xsl:text>
                <xsl:value-of select="$objectPropertyName"/>
            </xsl:variable>
            
            <!-- ..... -->
            
            <!-- min cardinality -->
            <xsl:variable name="minCardinality">
                <xsl:value-of select="//packagedElement[@xmi:type='uml:Association'][@xmi:id=$associationID]/ownedEnd/lowerValue/@value"/>
            </xsl:variable>
            
            <!-- max cardinality -->
            <xsl:variable name="maxCardinality">
                <xsl:value-of select="//packagedElement[@xmi:type='uml:Association'][@xmi:id=$associationID]/ownedEnd/upperValue/@value"/>
            </xsl:variable>
            
            <xsl:text disable-output-escaping="yes"><![CDATA[	
    <!-- source cardinality -->
    <rdf:Description rdf:about="]]></xsl:text><xsl:value-of select="$targetClassIRI"/><xsl:text disable-output-escaping="yes"><![CDATA[">
        <rdfs:subClassOf>
            <owl:Restriction>
                <owl:onProperty>
                    <rdf:Description>
                        <owl:inverseOf rdf:resource="]]></xsl:text><xsl:value-of select="$objectPropertyIRI"/><xsl:text disable-output-escaping="yes"><![CDATA["/>
                    </rdf:Description>
                </owl:onProperty>
                <owl:onClass rdf:resource="]]></xsl:text><xsl:value-of select="$sourceClassIRI"/><xsl:text disable-output-escaping="yes"><![CDATA["/>]]></xsl:text>
            <xsl:if test="//packagedElement[@xmi:type='uml:Association'][@xmi:id=$associationID]/ownedEnd/lowerValue/@value!= '0'">
                <xsl:text disable-output-escaping="yes"><![CDATA[
                <owl:minCardinality rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">]]></xsl:text><xsl:value-of select="$minCardinality"/><xsl:text disable-output-escaping="yes"><![CDATA[</owl:minCardinality>]]></xsl:text>
            </xsl:if>
            <xsl:if test="//packagedElement[@xmi:type='uml:Association'][@xmi:id=$associationID]/ownedEnd/upperValue/@value != '-1'">
                <xsl:text disable-output-escaping="yes"><![CDATA[
                <owl:maxCardinality rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">]]></xsl:text><xsl:value-of select="$maxCardinality"/><xsl:text disable-output-escaping="yes"><![CDATA[</owl:maxCardinality>]]></xsl:text>
            </xsl:if>
            <xsl:text disable-output-escaping="yes"><![CDATA[
            </owl:Restriction>
        </rdfs:subClassOf>
    </rdf:Description>
]]>     </xsl:text>
            
        </xsl:if>
        
    </xsl:template>
    <!-- ..... -->
    
    <!-- ............... -->
    <!-- target cardinality -->
    <xsl:template match="ownedAttribute" mode="targetCardinality">
        
        <!-- target cardinality only if either min or max cardinalities exist for specific association -->
        <xsl:if test="(./lowerValue or ./upperValue) and (./lowerValue/@value != '0' or ./upperValue/@value != '-1')">
            
            <!-- association ID -->
            <xsl:variable name="associationID">
                <xsl:value-of select="./@association"/>
            </xsl:variable>
            
            <!-- ............... -->
            <!-- source class IRI -->
            
            <!-- source class ID -->
            <xsl:variable name="sourceClassID">
                <xsl:value-of select="//packagedElement[@xmi:type='uml:Association'][@xmi:id=$associationID]/ownedEnd/type/@xmi:idref"/>
            </xsl:variable>
            
            <!-- source class name -->
            <xsl:variable name="sourceClassName">
                <xsl:value-of select="ddifunc:rename(//packagedElement[@xmi:type='uml:Class'][@xmi:id=$sourceClassID]/@name, 'class')"/>
            </xsl:variable>
            
            <!-- source class package name -->
            <xsl:variable name="sourceClassPackageName">
                <xsl:value-of select="ddifunc:rename(//packagedElement[@xmi:type='uml:Class'][@xmi:id=$sourceClassID]/..[@xmi:type='uml:Package']/@name, 'package')"/>
            </xsl:variable>
            
            <!-- source class IRI -->
            <xsl:variable name="sourceClassIRI">
                <xsl:value-of select="$baseOntologyIRI"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="$sourceClassPackageName"/>
                <xsl:text>#</xsl:text>
                <xsl:value-of select="$sourceClassName"/>
            </xsl:variable>
            
            <!-- ..... -->
            
            <!-- ............... -->
            <!-- target class IRI -->
            
            <!-- target class ID -->
            <xsl:variable name="targetClassID">
                <xsl:value-of select="./type/@xmi:idref"/>
            </xsl:variable>
            
            <!-- target class name -->
            <xsl:variable name="targetClassName">
                <xsl:value-of select="ddifunc:rename(//packagedElement[@xmi:type='uml:Class'][@xmi:id=$targetClassID]/@name, 'class')"/>
            </xsl:variable>
            
            <!-- target class package name -->
            <xsl:variable name="targetClassPackageName">
                <xsl:value-of select="ddifunc:rename(//packagedElement[@xmi:type='uml:Class'][@xmi:id=$targetClassID]/..[@xmi:type='uml:Package']/@name, 'package')"/>
            </xsl:variable>
            
            <!-- target class IRI -->
            <xsl:variable name="targetClassIRI">
                <xsl:value-of select="$baseOntologyIRI"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="$targetClassPackageName"/>
                <xsl:text>#</xsl:text>
                <xsl:value-of select="$targetClassName"/>
            </xsl:variable>
            
            <!-- ..... -->
            
            <!-- ............... -->
            <!-- object property IRI -->
            
            <!-- object property name -->
            <xsl:variable name="objectPropertyName">
                <xsl:choose>
                    <xsl:when test="//packagedElement[@xmi:type='uml:Association'][@xmi:id=$associationID]/@name">
                        <xsl:value-of select="ddifunc:rename(//packagedElement[@xmi:type='uml:Association'][@xmi:id=$associationID]/@name, 'property')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$compositionName"></xsl:value-of>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <!-- object property IRI -->
            <xsl:variable name="objectPropertyIRI">
                <xsl:value-of select="$baseOntologyIRI"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="$sourceClassPackageName"/>
                <xsl:text>#</xsl:text>
                <xsl:value-of select="$objectPropertyName"/>
            </xsl:variable>
            
            <!-- ..... -->
            
            <!-- min cardinality -->
            <xsl:variable name="minCardinality">
                <xsl:value-of select="./lowerValue/@value"/>
            </xsl:variable>
            
            <!-- max cardinality -->
            <xsl:variable name="maxCardinality">
                <xsl:value-of select="./upperValue/@value"/>
            </xsl:variable>
            
            <xsl:text disable-output-escaping="yes"><![CDATA[	
    <!-- target cardinality -->
    <rdf:Description rdf:about="]]></xsl:text><xsl:value-of select="$sourceClassIRI"/><xsl:text disable-output-escaping="yes"><![CDATA[">
        <rdfs:subClassOf>
            <owl:Restriction>
                <owl:onProperty rdf:resource="]]></xsl:text><xsl:value-of select="$objectPropertyIRI"/><xsl:text disable-output-escaping="yes"><![CDATA["/>
                <owl:onClass rdf:resource="]]></xsl:text><xsl:value-of select="$targetClassIRI"/><xsl:text disable-output-escaping="yes"><![CDATA["/>]]></xsl:text>
            <xsl:if test="./lowerValue/@value != '0'">
                <xsl:text disable-output-escaping="yes"><![CDATA[
                <owl:minCardinality rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">]]></xsl:text><xsl:value-of select="$minCardinality"/><xsl:text disable-output-escaping="yes"><![CDATA[</owl:minCardinality>]]></xsl:text>
            </xsl:if>
            <xsl:if test="./upperValue/@value != '-1'">
                <xsl:text disable-output-escaping="yes"><![CDATA[
                <owl:maxCardinality rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">]]></xsl:text><xsl:value-of select="$maxCardinality"/><xsl:text disable-output-escaping="yes"><![CDATA[</owl:maxCardinality>]]></xsl:text>
            </xsl:if>
            <xsl:text disable-output-escaping="yes"><![CDATA[
            </owl:Restriction>
        </rdfs:subClassOf>
    </rdf:Description>
]]>     </xsl:text>
            
        </xsl:if>
        
    </xsl:template>
    <!-- ..... -->
    
    <!-- ............... -->
    <!-- RDF document header -->
    <xsl:template name="rdfDocumentHeader">
        
        <xsl:text disable-output-escaping="yes"><![CDATA[	
<rdf:RDF
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl="http://www.w3.org/2002/07/owl#">
]]>     </xsl:text>
        
    </xsl:template>
    <!-- ..... -->
    
    <!-- ............... -->
    <!-- RDF document end -->
    <xsl:template name="rdfDocumentEnd">
        
        <xsl:text disable-output-escaping="yes"><![CDATA[	
</rdf:RDF>
]]></xsl:text>
        
    </xsl:template>
    <!-- ..... -->
    
    <!-- ............... -->
    <!-- ontology metadata -->
    <xsl:template name="ontologyMetadata">
        
        <xsl:text disable-output-escaping="yes"><![CDATA[
    <owl:Ontology rdf:about="]]></xsl:text>
            <xsl:value-of select="$baseOntologyIRI"/><xsl:text disable-output-escaping="yes"><![CDATA[">
        <rdfs:label xml:lang="en">DDI Core Vocabulary</rdfs:label>
        <rdfs:comment xml:lang="en">This is the DDI Core Vocabulary, an RDF Schema vocabulary that defines foundational concepts For describing the domain of statistics.</rdfs:comment>
    </owl:Ontology>
]]>     </xsl:text>
        
    </xsl:template>
    <!-- ..... -->
    
</xsl:stylesheet>