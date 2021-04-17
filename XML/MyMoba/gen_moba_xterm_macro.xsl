<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:functx="http://www.functx.com"
    exclude-result-prefixes="xs" version="2.0">
    <xsl:variable name="new_line">
        <xsl:text>&#10;</xsl:text>
    </xsl:variable>
    <xsl:variable name="carriage_return">
        <xsl:text>&#13;</xsl:text>
    </xsl:variable>

    <xsl:variable name="fr" select="('&quot;', ':', '=', '#', ';', '\|')"/>
    <xsl:variable name="to"
        select="('__DBLQUO__', '__DBLDOT__', '__EQQUAL__', '__DIEZE__', '__PTVIRG__', '__PIIPE__')"/>

    <xsl:function name="functx:if-absent" as="item()*" xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="item()*"/>
        <xsl:param name="value" as="item()*"/>

        <xsl:sequence
            select="
                if (exists($arg))
                then
                    $arg
                else
                    $value
                "/>

    </xsl:function>
    <xsl:function name="functx:replace-multi" as="xs:string?" xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="changeFrom" as="xs:string*"/>
        <xsl:param name="changeTo" as="xs:string*"/>

        <xsl:sequence
            select="
                if (count($changeFrom) > 0)
                then
                    functx:replace-multi(
                    replace($arg, $changeFrom[1],
                    functx:if-absent($changeTo[1], '')),
                    $changeFrom[position() > 1],
                    $changeTo[position() > 1])
                else
                    $arg
                "/>

    </xsl:function>
    <xsl:output method="html" indent="yes"/>
    <xsl:template match="/">
        <xsl:variable name="v_macro">
            <xsl:value-of select="/xmoba_macros/file"/>
            <xsl:text>.mxtmacros</xsl:text>
        </xsl:variable>
        <xsl:variable name="v_macro_document">
            <xsl:value-of select="/xmoba_macros/file"/>
            <xsl:text>_help.html</xsl:text>
        </xsl:variable>

        <ul>
            <li>
                <xsl:value-of select="$v_macro"/>
            </li>
            <li>
                <xsl:value-of select="$v_macro_document"/>
            </li>
        </ul>
        <table>
            <xsl:for-each select="//macro">
                <tr>
                    <td>
                        <xsl:text>git add </xsl:text>
                        <xsl:value-of select="@xml:base"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
        <xsl:result-document method="xhtml" href="{$v_macro_document}">
            <html>
                <head>
                    <style type="text/css">
                        h1.intro {
                            color: blue;
                        }
                        *.attention {
                            color: red;
                        }
                        *.css_warning {
                            background-color: #FBEFEF;
                        }
                        *.code {
                            background-color: #FBFBEF;
                        }
                        *.check {
                            background-color: #FBEFEF;
                        }
                        *.judge {
                            background-color: #FBFBEF;
                        }
                        *.align {
                            background-color: #E0ECF8;
                        }</style>
                    <title>
                        <xsl:value-of select="/xmoba_macros/file"/>
                    </title>
                </head>
                <body>
                    <h1>
                        <xsl:value-of select="/xmoba_macros/file"/>
                    </h1>
                    <table border="1">
                        <tr>
                            <th>Name</th>
                            <th>Desc</th>
                            <th>Environment</th>
                            <th>Definition</th>
                        </tr>
                        <xsl:for-each select="//macro">
                            <xsl:sort
                                select="concat(substring(upper-case(environment), 1, 1), '_', name)"
                                order="ascending"/>
                            <tr>
                                <td>
                                    <xsl:value-of
                                        select="concat(substring(upper-case(environment), 1, 1), '_', name)"
                                    />
                                </td>
                                <td>
                                    <xsl:value-of select="desc"/>
                                </td>
                                <td>
                                    <xsl:value-of select="environment"/>
                                </td>
                                <td>
                                    <ul>
                                        <xsl:for-each select="line">
                                            <li>
                                                <xsl:if test="@type eq 'KeyPress'">
                                                  <xsl:value-of select="@type"/>
                                                  <xsl:text>:</xsl:text>
                                                </xsl:if>
                                                <xsl:value-of select="."/>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </table>
                </body>
            </html>

        </xsl:result-document>

        <xsl:result-document method="text" href="{$v_macro}">
            <xsl:text>[Macros]</xsl:text>
            <xsl:value-of select="$new_line"/>
            <xsl:for-each select="/xmoba_macros/macro">
                <xsl:sort select="name" order="ascending"/>
                <xsl:value-of select="substring(upper-case(environment), 1, 1)"/>
                <xsl:text>_</xsl:text>
                <xsl:value-of select="name"/>
                <xsl:text>=</xsl:text>
                <xsl:for-each select="line">
                    <xsl:choose>
                        <xsl:when test="@type = 'Text'">
                            <xsl:text>12:0:0:</xsl:text>
                        </xsl:when>
                        <xsl:when test="@type = 'KeyPress'">
                            <xsl:choose>
                                <xsl:when test=". eq 'RETURN'">
                                    <xsl:text>258:13:1835009:</xsl:text>
                                </xsl:when>
                                <xsl:when test=". eq 'ESCAPE'">
                                    <xsl:text>258:27:65537:</xsl:text>
                                </xsl:when>
                                <xsl:when test=". eq 'COLON'">
                                    <xsl:text>258:58:2555905:</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:value-of select="functx:replace-multi(., $fr, $to)"/>
                    <xsl:text>|</xsl:text>
                </xsl:for-each>
                <xsl:value-of select="$new_line"/>
            </xsl:for-each>

            <xsl:text>[MacrosHotkeys]</xsl:text>
            <xsl:value-of select="$new_line"/>
            <xsl:for-each select="/xmoba_macros/macro">
                <xsl:sort select="name" order="ascending"/>
                <xsl:value-of select="substring(upper-case(environment), 1, 1)"/>
                <xsl:text>_</xsl:text>
                <xsl:value-of select="name"/>
                <xsl:text>=</xsl:text>
                <xsl:value-of select="hotkey"/>
                <xsl:value-of select="$new_line"/>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
