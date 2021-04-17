<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:output method="html" indent="yes"/>
    <xsl:template match="/">
        <xsl:variable name="sub_dir" select="/codes/directory"/>
        <table>
            <xsl:for-each select="//file">
                <xsl:variable name="v_file_name" select="."/>
                <xsl:variable name="full_file"
                    select="replace(unparsed-text(concat($sub_dir, '/', .)), '\r', '')"/>
                <xsl:variable name="file_name" select="substring-before(., '.')"/>
                <xsl:variable name="suffix" select="substring-after(., '.')"/>
                <xsl:variable name="out_file_name" select="concat($file_name, '.xml')"/>
                <tr>
                    <td>
                        <xsl:text>git add </xsl:text>
                        <xsl:text>../</xsl:text>
                        <xsl:value-of select="$sub_dir"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$out_file_name"/>
                    </td>
                </tr>
                <tr>
                    <td>
                        <xsl:text>git add </xsl:text>
                        <xsl:text>../</xsl:text>
                        <xsl:value-of select="$sub_dir"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$v_file_name"/>
                    </td>
                </tr>
            </xsl:for-each>
            <xsl:for-each select="//file">
                <xsl:variable name="v_file_name" select="."/>
                <xsl:variable name="full_file"
                    select="replace(unparsed-text(concat($sub_dir, '/', .)), '\r', '')"/>
                <xsl:variable name="file_name" select="substring-before(., '.')"/>
                <xsl:variable name="suffix" select="substring-after(., '.')"/>
                <xsl:variable name="out_file_name" select="concat($file_name, '.xml')"/>
                <xsl:variable name="action" select="@action"/>
                <tr>
                    <td>
                        <xsl:text>&lt;xi:include href=&quot;</xsl:text>
                        <xsl:text>../</xsl:text>
                        <xsl:value-of select="$sub_dir"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$out_file_name"/>
                        <xsl:text>&quot;/&gt;</xsl:text>
                    </td>
                </tr>
                <xsl:result-document method="xml" href="{$out_file_name}" indent="yes">
                    <macro xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                        xsi:noNamespaceSchemaLocation="../MobaMacro.xsd">
                        <name>
                            <xsl:value-of select="$file_name"/>
                        </name>
                        <desc>
                            <xsl:text>Full code file: </xsl:text>
                            <xsl:value-of select="."/>
                        </desc>
                        <environment>
                            <xsl:choose>
                                <xsl:when test="$action eq 'Help'">
                                    <xsl:text>Help</xsl:text>
                                </xsl:when>
                                <xsl:when test="$action eq 'WebBrowser'">
                                    <xsl:text>WebBrowser</xsl:text>
                                </xsl:when>
                                <xsl:when test="$action eq 'vi'">
                                    <xsl:text>Vi</xsl:text>
                                </xsl:when>
                                <xsl:when test="$suffix eq 'sql'">
                                    <xsl:text>SQLPlus</xsl:text>
                                </xsl:when>
                                <xsl:when test="$suffix eq 'ksh'">
                                    <xsl:text>KornShell</xsl:text>
                                </xsl:when>
                                <xsl:when test="$suffix eq 'bash'">
                                    <xsl:text>Bourne-again shell</xsl:text>
                                </xsl:when>
                                <xsl:when test="$suffix eq 'rman'">
                                    <xsl:text>RMAN</xsl:text>
                                </xsl:when>
                                <xsl:when test="$suffix eq 'bat'">
                                    <xsl:text>cmd</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </environment>
                        <hotkey>0</hotkey>
                        <xsl:choose>
                            <xsl:when test="$action eq 'WebBrowser'">
                                <line type="Text">
                                    <xsl:text>"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" </xsl:text>
                                </line>
                            </xsl:when>
                            <xsl:when test="$action eq 'vi'">
                                <line type="Text">
                                    <xsl:text>vi </xsl:text>
                                    <xsl:value-of select="$v_file_name"/>
                                </line>
                                <line type="KeyPress">RETURN</line>
                                <line type="KeyPress">COLON</line>
                                <line type="Text">1,$ d</line>
                                <line type="KeyPress">RETURN</line>
                                <line type="Text">i</line>
                            </xsl:when>
                            <xsl:when test="$action eq 'Help'">
                                <line type="Text">
                                    <xsl:text>cat &lt;&lt; 'EOH'</xsl:text>
                                </line>
                                <line type="KeyPress">RETURN</line>
                            </xsl:when>
                        </xsl:choose>

                        <xsl:analyze-string select="$full_file" regex="(.+?)\n">
                            <xsl:matching-substring>
                                <line type="Text">
                                    <xsl:value-of select="regex-group(1)"/>
                                </line>
                                <line type="KeyPress">RETURN</line>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                        <xsl:choose>
                            <xsl:when test="$action eq 'vi'">
                                <line type="KeyPress">ESCAPE</line>
                                <line type="KeyPress">COLON</line>
                                <line type="Text">x</line>
                                <line type="KeyPress">RETURN</line>
                            </xsl:when>
                            <xsl:when test="$action eq 'Help'">
                                <line type="Text">
                                    <xsl:text>EOH</xsl:text>
                                </line>
                                <line type="KeyPress">RETURN</line>
                            </xsl:when>
                        </xsl:choose>
                    </macro>
                </xsl:result-document>
            </xsl:for-each>
        </table>
    </xsl:template>

</xsl:stylesheet>
