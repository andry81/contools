<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text"/>
	<xsl:strip-space elements="*"/>
	<xsl:template match="*">
		<xsl:for-each select="ancestor-or-self::*">
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
		</xsl:for-each>
		<xsl:text>&#xA;</xsl:text>
		<xsl:apply-templates select="*"/>
	</xsl:template>
</xsl:stylesheet>
