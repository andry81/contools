<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text"/>
	<xsl:strip-space elements="*"/>
	<xsl:variable name="vApos">'</xsl:variable>
	<xsl:template match="*">
		<xsl:if test="not(*)">
			<xsl:apply-templates select="ancestor-or-self::*" mode="path"/>
			<xsl:text>&#xA;</xsl:text>
		</xsl:if>
		<xsl:apply-templates select="@*|*"/>
	</xsl:template>
	<xsl:template match="*" mode="path">
		<xsl:value-of select="concat('/', name())"/>
		<!-- <xsl:variable name="vnumSiblings" select="(preceding-sibling::*|following-sibling::*)[name()=name(current())]"/> -->
		<xsl:variable name="vnumSiblings" select="count(../*[name()=name(current())])"/>
		<xsl:if test="$vnumSiblings &gt; 1">
			<xsl:value-of select="concat('[',
				count(preceding-sibling::*[
					name()=name(current())
				])+1,
			']')"/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="@*">
		<xsl:apply-templates select="../ancestor-or-self::*" mode="path"/>
		<xsl:value-of select="concat('[@', name(), '=', $vApos, ., $vApos, ']')"/>
		<xsl:text>&#xA;</xsl:text>
	</xsl:template>
</xsl:stylesheet>
