<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ddifunc="ddi:functions"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:function name="ddifunc:to-upper-cc">
        <xsl:param name="content"/>
        <xsl:value-of select="upper-case(substring($content, 1, 1))"/>
        <xsl:value-of select="substring($content, 2)"/>
    </xsl:function>
	
	<xsl:function name="ddifunc:to-lower-cc">
        <xsl:param name="content"/>
        <xsl:value-of select="lower-case(substring($content, 1, 1))"/>
        <xsl:value-of select="substring($content, 2)"/>
    </xsl:function>
    
    <xsl:function name="ddifunc:upper-case-first" as="xs:string?">
        <xsl:param name="arg" as="xs:string?"/> 
        
        <xsl:sequence select=" 
            concat(upper-case(substring($arg,1,1)),
            substring($arg,2))
            "/>
        
    </xsl:function>
    
    <xsl:function name="ddifunc:lower-case-first" as="xs:string?">
        <xsl:param name="arg" as="xs:string?"/> 
        
        <xsl:sequence select=" 
            concat(lower-case(substring($arg,1,1)),
            substring($arg,2))
            "/>
        
    </xsl:function>
    
    <!-- rename according to naming conventions -->
    <xsl:function name="ddifunc:rename" as="xs:string?">
        <xsl:param name="name" as="xs:string?"/>
        <xsl:param name="type" as="xs:string?"/>
        
        <xsl:choose>
            <!-- package -->
            <xsl:when test="$type = 'package'">
                <xsl:value-of select="ddifunc:upper-case-first(encode-for-uri($name))"/>
            </xsl:when>
            <!-- class -->
            <xsl:when test="$type = 'class'">
                <xsl:value-of select="ddifunc:upper-case-first(ddifunc:replaceUnderscore(ddifunc:camelize($name)))"/>
            </xsl:when>
            <!-- property -->
            <xsl:when test="$type = 'property'">
                <xsl:value-of select="ddifunc:lower-case-first(ddifunc:replaceUnderscore(ddifunc:camelize($name)))"/>
            </xsl:when>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="ddifunc:replaceUnderscore" as="xs:string?">
        <xsl:param name="arg" as="xs:string?"/> 
        
        <xsl:value-of select="translate($arg, '_', '')"/>
        
    </xsl:function>
    
    <xsl:function name="ddifunc:camelize" as="xs:string">
        <xsl:param name="arg" as="xs:string?"/> 
        
        <xsl:sequence select="
            string-join((tokenize($arg,'\s+')[1],
            for $word in tokenize($arg,'\s+')[position() > 1]
            return ddifunc:upper-case-first($word))
            ,'')
            "/>
        
    </xsl:function>
	
	<xsl:function name="ddifunc:uncamelize">
        <xsl:param name="content"/>
	    <xsl:value-of select="lower-case(replace($content, '([a-z])([A-Z])', '$1 $2'))"/>
    </xsl:function>
	
</xsl:stylesheet>