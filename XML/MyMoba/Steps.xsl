<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:axi="http://www.w3.org/1999/XSL/TransformAlias" xmlns:xi="http://www.w3.org/2001/XInclude"
    exclude-result-prefixes="xs" version="2.0">

    <xsl:output indent="yes" method="xml"/>

    <xsl:namespace-alias stylesheet-prefix="axi" result-prefix="xi"/>

    <xsl:variable name="v_packingdir">
        <xsl:value-of select="//macro_dir/@packingdir"/>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:variable name="v_repository_dir">
            <xsl:choose>
                <xsl:when test="string-length(//repository_dir) > 1">
                    <xsl:value-of select="//repository_dir"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>MyMoba</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_macro_dir">
            <xsl:value-of select="//macro_dir"/>
        </xsl:variable>

        <xsl:variable name="v_note_file">
            <xsl:text>note.sh</xsl:text>
        </xsl:variable>

        <xsl:variable name="v_network_path">
            <xsl:text>/u01/MobaHelp/</xsl:text>
        </xsl:variable>

        <xsl:result-document href="{$v_note_file}" method="text">
            <xsl:for-each select="//group">
                <xsl:variable name="v_group">
                    <xsl:copy-of select="."/>
                </xsl:variable>
                <xsl:variable name="v_subdir">
                    <xsl:value-of select="subdir"/>
                </xsl:variable>
                <xsl:variable name="v_team_dir">
                    <xsl:value-of select="$v_network_path"/>
                    <xsl:value-of select="$v_repository_dir"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="$v_macro_dir"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="$v_subdir"/>
                </xsl:variable>
                <xsl:text>ssh oracle@bsworaredhat01 mkdir -p </xsl:text>
                <xsl:value-of select="$v_team_dir"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:for-each select="$v_group//step">
                    <xsl:text>scp /home/mobaxterm/</xsl:text>
                    <xsl:value-of select="$v_repository_dir"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="$v_macro_dir"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="$v_subdir"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text> oracle@bsworaredhat01:</xsl:text>
                    <xsl:value-of select="$v_team_dir"/>
                    <xsl:text>&#10;</xsl:text>
                </xsl:for-each>
                <xsl:text>ssh oracle@bsworaredhat01 ls -l </xsl:text>
                <xsl:value-of select="$v_team_dir"/>
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>

        <xsl:variable name="v_alias_pack_file">
            <xsl:text>alias_pack.sh</xsl:text>
        </xsl:variable>

        <xsl:variable name="v_alias_define_file">
            <xsl:value-of select="//macro_dir/@packingdir"/>
            <xsl:text>/alias_define.sh</xsl:text>
        </xsl:variable>

        <xsl:if test="//macro_dir/@packingdir">
            <xsl:result-document href="{$v_alias_pack_file}" method="text">
                <xsl:for-each select="//group[step/@aliss]">
                    <xsl:variable name="v_group">
                        <xsl:copy-of select="."/>
                    </xsl:variable>
                    <xsl:variable name="v_subdir">
                        <xsl:value-of select="subdir"/>
                    </xsl:variable>
                    <xsl:variable name="v_team_dir">
                        <xsl:text>/home/mobaxterm/</xsl:text>
                        <xsl:value-of select="$v_repository_dir"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$v_macro_dir"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="//macro_dir/@packingdir"/>
                    </xsl:variable>
                    <xsl:if test="position() = 1">
                        <xsl:text>ssh oracle@bsworaredhat01 mkdir -p </xsl:text>
                        <xsl:value-of select="$v_team_dir"/>
                        <xsl:text>&#10;</xsl:text>
                    </xsl:if>
                    <xsl:for-each select="$v_group//step[@aliss]">
                        <xsl:text>scp /home/mobaxterm/</xsl:text>
                        <xsl:value-of select="$v_repository_dir"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$v_macro_dir"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$v_subdir"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$v_team_dir"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="@aliss"/>
                        <xsl:text>_</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>&#10;</xsl:text>
                    </xsl:for-each>
                    <xsl:if test="position() = last()">

                        <xsl:text>ssh oracle@bsworaredhat01 ls -l </xsl:text>
                        <xsl:value-of select="$v_team_dir"/>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>cd  </xsl:text>
                        <xsl:value-of select="$v_team_dir"/>
                        <xsl:text>/..</xsl:text>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>rm  </xsl:text>
                        <xsl:value-of select="replace(//macro_dir/@packingdir, '\.', '_')"/>
                        <xsl:text>.zip</xsl:text>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>zip -r  </xsl:text>
                        <xsl:value-of select="replace(//macro_dir/@packingdir, '\.', '_')"/>
                        <xsl:text>.zip</xsl:text>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="//macro_dir/@packingdir"/>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>zip -T  </xsl:text>
                        <xsl:value-of select="replace(//macro_dir/@packingdir, '\.', '_')"/>
                        <xsl:text>.zip</xsl:text>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>unzip -vl  </xsl:text>
                        <xsl:value-of select="replace(//macro_dir/@packingdir, '\.', '_')"/>
                        <xsl:text>.zip</xsl:text>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>rsync -avh --delete /home/mobaxterm/MyMoba/</xsl:text>
                        <xsl:value-of select="$v_macro_dir"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$v_packingdir"/>
                        <xsl:text> /home/mobaxterm/MyMoba/Alias/</xsl:text>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>echo scp </xsl:text>
                        <xsl:value-of select="replace(//macro_dir/@packingdir, '\.', '_')"/>
                        <xsl:text>.zip oracle@cmparch.bhcs.pvt:/archivelog/oradata/CLIHelpAlias/</xsl:text>
                        <xsl:value-of select="replace(//macro_dir/@packingdir, '\.', '_')"/>
                        <xsl:text>.zip</xsl:text>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>echo scp oracle@cmparch.bhcs.pvt:/archivelog/oradata/CLIHelpAlias/</xsl:text>
                        <xsl:value-of select="replace(//macro_dir/@packingdir, '\.', '_')"/>
                        <xsl:text>.zip </xsl:text>
                        <xsl:value-of select="replace(//macro_dir/@packingdir, '\.', '_')"/>
                        <xsl:text>.zip</xsl:text>
                        <xsl:text>&#10;</xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:result-document>

            <xsl:result-document href="{$v_alias_define_file}" method="text">
                <xsl:for-each select="//group">
                    <xsl:variable name="v_group">
                        <xsl:copy-of select="."/>
                    </xsl:variable>
                    <xsl:for-each select="$v_group//step[@aliss]">
                        <xsl:text>alias </xsl:text>
                        <xsl:value-of select="@aliss"/>
                        <xsl:text>='CLS;cat ${ALIAS_DIR}/</xsl:text>
                        <xsl:value-of select="$v_packingdir"/>
                        <xsl:value-of select="//macro_dir/@packingdir"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="@aliss"/>
                        <xsl:text>_</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>'</xsl:text>
                        <xsl:text>&#10;</xsl:text>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:result-document>


        </xsl:if>
        <all_codes>

            <codes>
                <dummy/>

                <xsl:comment>Include this begining marker</xsl:comment>

                <xsl:for-each select="//group">
                    <xsl:variable name="v_prefix">
                        <xsl:choose>
                            <xsl:when test="string-length(prefix) &gt; 0">
                                <xsl:value-of select="prefix"/>
                                <xsl:text>_</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="v_subdir">
                        <xsl:value-of select="subdir"/>
                    </xsl:variable>
                    <xsl:for-each select="step">
                        <xsl:variable name="v_bear_file">
                            <xsl:value-of select="substring-before(., '.')"/>
                        </xsl:variable>

                        <xsl:variable name="v_macro_file">
                            <xsl:value-of select="$v_prefix"/>
                            <xsl:value-of select="format-number(10 * position(), '000')"/>
                            <xsl:text>_</xsl:text>
                            <xsl:value-of select="$v_bear_file"/>
                        </xsl:variable>
                        <xsl:variable name="v_team_macro_xml">
                            <xsl:value-of select="$v_prefix"/>
                            <xsl:value-of select="format-number(10 * position(), '0000')"/>
                            <xsl:text>_</xsl:text>
                            <xsl:value-of select="$v_bear_file"/>
                            <xsl:text>.xml</xsl:text>
                        </xsl:variable>
                        <xsl:variable name="v_macro_xml">
                            <xsl:value-of select="$v_macro_file"/>
                            <xsl:text>.xml</xsl:text>
                        </xsl:variable>
                        <xsl:variable name="v_cat_file">
                            <xsl:text>./</xsl:text>
                            <xsl:value-of select="$v_subdir"/>
                            <xsl:text>/-</xsl:text>
                            <xsl:value-of select="."/>
                        </xsl:variable>
                        <!-- 
                    <macro_file>
                        <xsl:value-of select="$v_macro_file"/>
                    </macro_file>
                    <cat_file>
                        <xsl:value-of select="$v_cat_file"/>
                    </cat_file>
                     -->
                        <axi:include>
                            <xsl:attribute name="href">
                                <xsl:text>../../</xsl:text>
                                <xsl:value-of select="$v_repository_dir"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="$v_macro_dir"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="$v_macro_xml"/>
                            </xsl:attribute>
                        </axi:include>
                        <xsl:result-document href="{$v_macro_xml}" method="xml" indent="yes">
                            <macro xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                                xsi:noNamespaceSchemaLocation="../MobaMacro.xsd">
                                <name>
                                    <xsl:value-of select="$v_macro_file"/>
                                </name>
                                <desc>
                                    <xsl:value-of select="$v_macro_file"/>
                                </desc>
                                <environment>MobaXterm</environment>
                                <hotkey>0</hotkey>
                                <line type="Text">
                                    <xsl:text>cls;cat </xsl:text>
                                    <xsl:text>/home/mobaxterm/</xsl:text>
                                    <xsl:value-of select="$v_repository_dir"/>
                                    <xsl:text>/</xsl:text>
                                    <xsl:value-of select="$v_macro_dir"/>
                                    <xsl:text>/</xsl:text>
                                    <xsl:value-of select="replace($v_cat_file, '-', '')"/>
                                </line>
                                <line type="KeyPress">RETURN</line>
                            </macro>
                        </xsl:result-document>

                        <xsl:result-document href="{$v_team_macro_xml}" method="xml" indent="yes">
                            <macro xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                                xsi:noNamespaceSchemaLocation="../MobaMacro.xsd">
                                <name>
                                    <xsl:value-of select="$v_macro_file"/>
                                </name>
                                <desc>
                                    <xsl:value-of select="$v_macro_file"/>
                                </desc>
                                <environment>MobaXterm</environment>
                                <hotkey>0</hotkey>
                                <line type="Text">
                                    <xsl:text>cls;ssh oracle@bsworaredhat01 cat </xsl:text>
                                    <xsl:text>/u01/MobaHelp/</xsl:text>
                                    <xsl:value-of select="$v_repository_dir"/>
                                    <xsl:text>/</xsl:text>
                                    <xsl:value-of select="$v_macro_dir"/>
                                    <xsl:text>/</xsl:text>
                                    <xsl:value-of select="replace($v_cat_file, '-', '')"/>
                                </line>
                                <line type="KeyPress">RETURN</line>
                            </macro>
                        </xsl:result-document>

                        <xsl:result-document href="{$v_cat_file}" method="text">
                            <xsl:text>File</xsl:text>
                            <xsl:text>&#10;</xsl:text>
                        </xsl:result-document>


                    </xsl:for-each>
                </xsl:for-each>
                <xsl:comment>Include this ending marker</xsl:comment>
            </codes>
            <codes>
                <dummy/>

                <xsl:comment>Include this begining marker</xsl:comment>
                <xsl:for-each select="//group">
                    <xsl:variable name="v_prefix">
                        <xsl:choose>
                            <xsl:when test="string-length(prefix) &gt; 0">
                                <xsl:value-of select="prefix"/>
                                <xsl:text>_</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:for-each select="step">

                        <xsl:variable name="v_bear_file">
                            <xsl:value-of select="substring-before(., '.')"/>
                        </xsl:variable>

                        <xsl:variable name="v_team_macro_xml">
                            <xsl:value-of select="$v_prefix"/>
                            <xsl:value-of select="format-number(10 * position(), '0000')"/>
                            <xsl:text>_</xsl:text>
                            <xsl:value-of select="$v_bear_file"/>
                            <xsl:text>.xml</xsl:text>
                        </xsl:variable>
                        <axi:include>
                            <xsl:attribute name="href">
                                <xsl:text>../../</xsl:text>
                                <xsl:value-of select="$v_repository_dir"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="$v_macro_dir"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="$v_team_macro_xml"/>
                            </xsl:attribute>
                        </axi:include>
                    </xsl:for-each>
                </xsl:for-each>
                <xsl:comment>Include this ending marker</xsl:comment>
            </codes>
        </all_codes>
    </xsl:template>

</xsl:stylesheet>
