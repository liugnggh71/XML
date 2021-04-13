<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:functx="http://www.functx.com"
    exclude-result-prefixes="xs" version="2.0">

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


    <xsl:function name="functx:repeat-string" as="xs:string" xmlns:functx="http://www.functx.com">
        <xsl:param name="stringToRepeat" as="xs:string?"/>
        <xsl:param name="count" as="xs:integer"/>

        <xsl:sequence
            select="
                string-join((for $i in 1 to $count
                return
                    $stringToRepeat),
                '')
                "/>

    </xsl:function>

    <xsl:function name="functx:pad-string-to-length" as="xs:string"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="stringToPad" as="xs:string?"/>
        <xsl:param name="padChar" as="xs:string"/>
        <xsl:param name="length" as="xs:integer"/>

        <xsl:sequence
            select="
                substring(
                string-join(
                ($stringToPad,
                for $i in (1 to $length)
                return
                    $padChar)
                , '')
                , 1, $length)
                "/>

    </xsl:function>
    <xsl:template name="get_indent">
        <xsl:variable name="v_indent_level">
            <xsl:value-of
                select="
                    sum(for $i in ancestor::*
                    return
                        $i/@indent)"
            />
        </xsl:variable>
        <xsl:value-of select="functx:repeat-string('  ', $v_indent_level)"/>
    </xsl:template>

    <xsl:template name="create_alias_file">
        <xsl:param name="p_project_role"/>
        <xsl:for-each-group select="/codes/*[name() = $p_project_role]/code[@alias]"
            group-by="@subdir">
            <xsl:variable name="v_stage_dir">
                <xsl:choose>
                    <xsl:when test="string-length(../@stage_dir) &gt; 0">
                        <xsl:value-of select="../@stage_dir"/>
                        <xsl:text>/</xsl:text>
                    </xsl:when>
                    <xsl:when test="string-length(../../@stage_dir) &gt; 0">
                        <xsl:value-of select="../../@stage_dir"/>
                        <xsl:text>/</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="v_alias_file">
                <xsl:value-of select="$v_stage_dir"/>
                <xsl:value-of select="@subdir"/>
                <xsl:text>/DA.sh</xsl:text>
            </xsl:variable>
            <xsl:variable name="v_unalias_file">
                <xsl:value-of select="$v_stage_dir"/>
                <xsl:value-of select="@subdir"/>
                <xsl:text>/UA.sh</xsl:text>
            </xsl:variable>
            <xsl:result-document href="{$v_alias_file}" method="text">
                <xsl:for-each select="current-group()">
                    <xsl:sort select="@alias"/>
                    <xsl:text>alias </xsl:text>
                    <xsl:value-of select="@alias"/>
                    <xsl:text>='</xsl:text>
                    <xsl:if test="@call_method = 'source'">
                        <xsl:text>. </xsl:text>
                    </xsl:if>
                    <xsl:text>./</xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>'</xsl:text>
                    <xsl:value-of select="$v_newline"/>
                </xsl:for-each>
                <xsl:for-each select="current-group()">
                    <xsl:sort select="@step"/>
                    <xsl:if test="string-length(@step) gt 0">
                        <xsl:text>alias </xsl:text>
                        <xsl:value-of select="@step"/>
                        <xsl:text>='</xsl:text>
                        <xsl:if test="@call_method = 'source'">
                            <xsl:text>. </xsl:text>
                        </xsl:if>
                        <xsl:text>./</xsl:text>
                        <xsl:value-of select="@name"/>
                        <xsl:text>'</xsl:text>
                        <xsl:value-of select="$v_newline"/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:text>alias C0='cat ./readme.txt'</xsl:text>
            </xsl:result-document>
            <xsl:result-document href="{$v_unalias_file}" method="text">
                <xsl:for-each select="current-group()">
                    <xsl:sort select="@alias"/>
                    <xsl:text>unalias </xsl:text>
                    <xsl:value-of select="@alias"/>
                    <xsl:value-of select="$v_newline"/>
                </xsl:for-each>
                <xsl:text>unalias C0</xsl:text>
            </xsl:result-document>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:output method="xml"/>

    <xsl:variable name="v_tns_template">
        <xsl:text><![CDATA[
TNS_stanza =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = HoST_nAMe)(PORT = PorT_NUmber))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = SerVICE_naME)
    )
  )
            ]]></xsl:text>
    </xsl:variable>

    <xsl:variable name="v_tns_replace_fr">
        <xsl:text>TNS_stanza:HoST_nAMe:PorT_NUmber:SerVICE_naME</xsl:text>
    </xsl:variable>

    <xsl:variable name="v_newline">
        <xsl:text>&#xa;</xsl:text>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:for-each select="/codes//code">
            <xsl:variable name="v_stage_dir">
                <xsl:choose>
                    <xsl:when test="string-length(../@stage_dir) &gt; 0">
                        <xsl:value-of select="../@stage_dir"/>
                        <xsl:text>/</xsl:text>
                    </xsl:when>
                    <xsl:when test="string-length(../../@stage_dir) &gt; 0">
                        <xsl:value-of select="../../@stage_dir"/>
                        <xsl:text>/</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="v_code_file">
                <xsl:value-of select="$v_stage_dir"/>
                <xsl:value-of select="@subdir"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="@name"/>
            </xsl:variable>
            <xsl:result-document href="{$v_code_file}" method="text">
                <xsl:for-each select="*">
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </xsl:result-document>
        </xsl:for-each>
        <!--<xsl:for-each-group select="/codes/active/code[@alias]" group-by="@subdir">
            <xsl:variable name="v_stage_dir">
                <xsl:choose>
                    <xsl:when test="string-length(../@stage_dir) &gt; 0">
                        <xsl:value-of select="../@stage_dir"/>
                        <xsl:text>/</xsl:text>
                    </xsl:when>
                    <xsl:when test="string-length(../../@stage_dir) &gt; 0">
                        <xsl:value-of select="../../@stage_dir"/>
                        <xsl:text>/</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="v_alias_file">
                <xsl:value-of select="$v_stage_dir"/>
                <xsl:value-of select="@subdir"/>
                <xsl:text>/DA.sh</xsl:text>
            </xsl:variable>
            <xsl:variable name="v_unalias_file">
                <xsl:value-of select="$v_stage_dir"/>
                <xsl:value-of select="@subdir"/>
                <xsl:text>/UA.sh</xsl:text>
            </xsl:variable>
            <xsl:result-document href="{$v_alias_file}" method="text">
                <xsl:for-each select="current-group()">
                    <xsl:sort select="@alias"/>
                    <xsl:text>alias </xsl:text>
                    <xsl:value-of select="@alias"/>
                    <xsl:text>='. ./</xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>'</xsl:text>
                    <xsl:value-of select="$v_newline"/>
                </xsl:for-each>
                <xsl:text>alias C0='cat ./readme.txt'</xsl:text>
            </xsl:result-document>
            <xsl:result-document href="{$v_unalias_file}" method="text">
                <xsl:for-each select="current-group()">
                    <xsl:sort select="@alias"/>
                    <xsl:text>unalias </xsl:text>
                    <xsl:value-of select="@alias"/>
                    <xsl:value-of select="$v_newline"/>
                </xsl:for-each>
                <xsl:text>unalias C0</xsl:text>
            </xsl:result-document>
        </xsl:for-each-group>
        -->
        <xsl:call-template name="create_alias_file">
            <xsl:with-param name="p_project_role" select="'dataguard'"/>
        </xsl:call-template>
        <xsl:call-template name="create_alias_file">
            <xsl:with-param name="p_project_role" select="'active'"/>
        </xsl:call-template>
        <xsl:call-template name="create_alias_file">
            <xsl:with-param name="p_project_role" select="'Test_code'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="steps">
        <xsl:for-each select="*">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="var_echo">
        <xsl:text>echo "</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>: $</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="$v_newline"/>
    </xsl:template>
    <xsl:template match="empty_line">
        <xsl:call-template name="get_indent"/>
        <xsl:text>empty_lines </xsl:text>
        <xsl:value-of select="."/>
        <xsl:value-of select="$v_newline"/>
    </xsl:template>

    <xsl:template match="else">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>else </xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <xsl:template match="echo">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>

        <xsl:if test="@wrapper and (@position = 'both' or @position = 'front')">
            <xsl:value-of select="$v_indent_string"/>
            <xsl:text>echo "</xsl:text>
            <xsl:value-of select="functx:pad-string-to-length('#', @wrapper, string-length(.))"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>echo "</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:if test="@wrapper and (@position = 'both' or @position = 'back')">
            <xsl:value-of select="$v_indent_string"/>
            <xsl:text>echo "</xsl:text>
            <xsl:value-of select="functx:pad-string-to-length('#', @wrapper, string-length(.))"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="empty_line_function">
        <xsl:text><![CDATA[
function empty_lines {
  a=1
  while [[ $a -le $1 ]]
  do
    echo ''
    a=$((a + 1))
  done
}
]]></xsl:text>
    </xsl:template>
    <xsl:template match="function">
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="$v_newline"/>
        <xsl:text># function definition for </xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:value-of select="$v_newline"/>
        <xsl:text># </xsl:text>
        <xsl:value-of select="@desc"/>
        <xsl:value-of select="$v_newline"/>
        <xsl:text>#~~~~~~~~~~~~~~~~~~FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF~~~~~~~~~~~~~~~~~#</xsl:text>

        <xsl:for-each select="steps/parameters[1]/parameter">
            <xsl:text># Parameter </xsl:text>
            <xsl:value-of select="position()"/>
            <xsl:text>: </xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text> -- </xsl:text>
            <xsl:value-of select="@desc"/>
            <xsl:text> DEFAULT ( </xsl:text>
            <xsl:value-of select="@default"/>
            <xsl:text> ) </xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:for-each>

        <xsl:value-of select="$v_newline"/>


        <xsl:text>function </xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text> {</xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:for-each select="*">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:text>}</xsl:text>
        <xsl:value-of select="$v_newline"/>
    </xsl:template>
    <xsl:template match="parameter"/>

    <xsl:template match="call_function">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>

        <xsl:if test="not(@inline = 'yes')">
            <xsl:value-of select="$v_newline"/>
            <xsl:value-of select="$v_indent_string"/>
        </xsl:if>
        <xsl:value-of select="@name"/>
        <xsl:text> </xsl:text>
        <xsl:for-each select="parameters/parameter">
            <xsl:value-of select="."/>
            <xsl:text> </xsl:text>
        </xsl:for-each>
        <xsl:apply-templates select="pipe"/>
        <xsl:if test="not(@inline = 'yes')">
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="source_shared_lib">
        <xsl:text><![CDATA[MY_CODE_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_CODE_DIR}" ]]; then DIR="${PWD}"; fi
export MY_CODE_DIR
. "${MY_CODE_DIR}/shared_lib.sh"
cd ${MY_CODE_DIR}
            ]]></xsl:text>
    </xsl:template>
    <xsl:template match="operand">
        <xsl:choose>
            <xsl:when test="@type = 'variable'">
                <xsl:text>${</xsl:text>
            </xsl:when>
            <xsl:when test="@type = 'constantChar'">
                <xsl:text>"</xsl:text>
            </xsl:when>
            <xsl:when test="@type = 'arithmetic'">
                <xsl:text>$((</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:value-of select="."/>
        <xsl:choose>
            <xsl:when test="@type = 'variable'">
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:when test="@type = 'constantChar'">
                <xsl:text>"</xsl:text>
            </xsl:when>
            <xsl:when test="@type = 'arithmetic'">
                <xsl:text>))</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="variable_assign">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>
        <xsl:if test="desc">
            <xsl:value-of select="$v_indent_string"/>
            <xsl:text># </xsl:text>
            <xsl:value-of select="desc"/>
            <xsl:value-of select="$v_newline"/>
            <xsl:value-of select="$v_indent_string"/>
            <xsl:text>#</xsl:text>
            <xsl:value-of select="functx:repeat-string('=', string-length(desc))"/>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:if test="export = 'yes'">
            <xsl:text>export </xsl:text>
        </xsl:if>
        <xsl:value-of select="name"/>
        <xsl:text>=</xsl:text>
        <xsl:choose>
            <xsl:when test="assign_type = 'arithmetic'">
                <xsl:text>$((</xsl:text>
            </xsl:when>
            <xsl:when test="assign_type = 'expression'">
                <xsl:text>$(</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:apply-templates select="assign"/>
        <!--<xsl:value-of select="assign "/>-->
        <xsl:choose>
            <xsl:when test="assign_type = 'arithmetic'">
                <xsl:text>))</xsl:text>
            </xsl:when>
            <xsl:when test="assign_type = 'expression'">
                <xsl:text>)</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="$v_newline"/>
    </xsl:template>
    <xsl:template match="operator">
        <xsl:choose>
            <xsl:when test=". = 'NumberGreater'">
                <xsl:text> -gt </xsl:text>
            </xsl:when>
            <xsl:when test=". = 'NumberGreaterEqual'">
                <xsl:text> -ge </xsl:text>
            </xsl:when>
            <xsl:when test=". = 'NumberLess'">
                <xsl:text> -lt </xsl:text>
            </xsl:when>
            <xsl:when test=". = 'NumberLessEqual'">
                <xsl:text> -le </xsl:text>
            </xsl:when>
            <xsl:when test=". = 'NumberEqual'">
                <xsl:text> -eq </xsl:text>
            </xsl:when>
            <xsl:when test=". = 'NumberNotEqual'">
                <xsl:text> -ne </xsl:text>
            </xsl:when>
            <xsl:when test=". = 'CharEqual'">
                <xsl:text> = </xsl:text>
            </xsl:when>
            <xsl:when test=". = 'CharNotEqual'">
                <xsl:text> != </xsl:text>
            </xsl:when>
            <xsl:when test=". = 'CharLess'">
                <xsl:text> \&lt; </xsl:text>
            </xsl:when>
            <xsl:when test=". = 'CharLessEqual'">
                <xsl:text> \&lt;= </xsl:text>
            </xsl:when>
            <xsl:when test=". = 'CharGreater'">
                <xsl:text> \&gt; </xsl:text>
            </xsl:when>
            <xsl:when test=". = 'CharGreaterEqual'">
                <xsl:text> \&gt;= </xsl:text>
            </xsl:when>
            <xsl:when test=". = 'CharLength'">
                <xsl:text> -n </xsl:text>
            </xsl:when>
            <xsl:when test=". = 'CharZeroLength'">
                <xsl:text> -z </xsl:text>
            </xsl:when>
            <xsl:when test=". = 'FileNotEmpty'">
                <xsl:text> -s </xsl:text>
            </xsl:when>
            <xsl:when test=". = 'FileEmpty'">
                <xsl:text> ! -s </xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="if_block">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>
        <xsl:for-each select="*">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>fi</xsl:text>
        <xsl:value-of select="$v_newline"/>
    </xsl:template>

    <xsl:template match="input">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>
        <xsl:value-of select="var"/>
        <xsl:text>=input(</xsl:text>
        <xsl:choose>
            <xsl:when test=" prompt/@quote eq 'single'">
                <xsl:text>'</xsl:text>
            </xsl:when>
            <xsl:when test=" prompt/@quote eq 'double'">
                <xsl:text>"</xsl:text>
            </xsl:when>
            <xsl:when test=" prompt/@quote eq 'triple'">
                <xsl:text>'''</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:value-of select="prompt"/>
        <xsl:choose>
            <xsl:when test=" prompt/@quote eq 'single'">
                <xsl:text>'</xsl:text>
            </xsl:when>
            <xsl:when test=" prompt/@quote eq 'double'">
                <xsl:text>"</xsl:text>
            </xsl:when>
            <xsl:when test=" prompt/@quote eq 'triple'">
                <xsl:text>'''</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>)</xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:if test="@show eq 'Y'">
            <xsl:text>print("Variable </xsl:text>
            <xsl:value-of select="var"/>
            <xsl:text> has value ", </xsl:text>
            <xsl:value-of select="var"/>
            <xsl:text> , " is ", type( </xsl:text>
            <xsl:value-of select="var"/>
            <xsl:text> )) </xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="test">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>

        <xsl:if test="../name() = 'if_block' and count(preceding-sibling::test) = 0">
            <xsl:value-of select="$v_indent_string"/>
            <xsl:text>if </xsl:text>
        </xsl:if>
        <xsl:if test="../name() = 'if_block' and count(preceding-sibling::test) > 0">
            <xsl:value-of select="$v_indent_string"/>
            <xsl:text>elif </xsl:text>
        </xsl:if>
        <xsl:text>[ </xsl:text>
        <xsl:apply-templates select="./*"/>
        <xsl:text> ] </xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:choose>
            <xsl:when test="../name() = 'if_block'">
                <xsl:value-of select="$v_indent_string"/>
                <xsl:text> then</xsl:text>
            </xsl:when>
            <xsl:when test="../name() = 'while_block'">
                <xsl:value-of select="$v_indent_string"/>
                <xsl:text> do</xsl:text>
            </xsl:when>
        </xsl:choose>

        <xsl:value-of select="$v_newline"/>
    </xsl:template>
    <xsl:template match="exit">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>
        <xsl:variable name="v_exit">
            <xsl:value-of select="$v_indent_string"/>
            <xsl:text>exit </xsl:text>
            <xsl:value-of select="."/>
            <xsl:value-of select="$v_newline"/>
        </xsl:variable>

        <xsl:variable name="v_XX">
            <xsl:value-of select="$v_indent_string"/>
            <xsl:text>#</xsl:text>
            <xsl:for-each select="1 to string-length($v_exit)">
                <xsl:text>X</xsl:text>
            </xsl:for-each>
            <xsl:value-of select="$v_newline"/>
        </xsl:variable>

        <xsl:value-of select="$v_XX"/>
        <xsl:value-of select="$v_exit"/>
        <xsl:value-of select="$v_XX"/>
    </xsl:template>
    <xsl:template match="return">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>
        <xsl:variable name="v_exit">
            <xsl:value-of select="$v_indent_string"/>
            <xsl:text>return </xsl:text>
            <xsl:value-of select="."/>
            <xsl:value-of select="$v_newline"/>
        </xsl:variable>

        <xsl:variable name="v_XX">
            <xsl:value-of select="$v_indent_string"/>
            <xsl:value-of
                select="functx:pad-string-to-length('#', 'Return ', string-length($v_exit))"/>
            <xsl:for-each select="1 to string-length($v_exit)">
                <xsl:text>X</xsl:text>
            </xsl:for-each>
            <xsl:value-of select="$v_newline"/>
        </xsl:variable>

        <xsl:value-of select="$v_XX"/>
        <xsl:value-of select="$v_exit"/>
        <xsl:value-of select="$v_XX"/>
    </xsl:template>
    <xsl:template match="run">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>#</xsl:text>
        <xsl:value-of select="@desc"/>
        <xsl:value-of select="$v_newline"/>

        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>#</xsl:text>
        <xsl:for-each select="1 to string-length(@desc)">
            <xsl:text>R</xsl:text>
        </xsl:for-each>
        <xsl:value-of select="$v_newline"/>

        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>echo "</xsl:text>
        <xsl:value-of select="@desc"/>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="$v_newline"/>

        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:value-of select="."/>
        <xsl:value-of select="$v_newline"/>
    </xsl:template>

    <xsl:template match="assign">
        <xsl:choose>
            <xsl:when test="count(current()/child::*) &gt; 0">
                <xsl:apply-templates select="*[string-length(name()) &gt; 0]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>

        <!--        <xsl:for-each select="*">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
-->
    </xsl:template>
    
    <xsl:template match="vInt">
        <xsl:value-of select="name"/>
        <xsl:text>=</xsl:text>
        <xsl:value-of select="value"/>
        <xsl:value-of select="$v_newline"/>
        <xsl:if test="@show eq 'Y'">
            <xsl:text>print("Variable </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> has value ", </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> , " is ", type( </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> )) </xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="vRange">
        <xsl:value-of select="name"/>
        <xsl:text>=range(</xsl:text>
        <xsl:value-of select="start"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="stop"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="step"/>
        <xsl:text>)</xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:if test="@show eq 'Y'">
            <xsl:text>print("Variable </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> has value ", </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> , " is ", type( </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> )) </xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="vBoolean">
        <xsl:value-of select="name"/>
        <xsl:text>=</xsl:text>
        <xsl:value-of select="value"/>
        <xsl:value-of select="$v_newline"/>
        <xsl:if test="@show eq 'Y'">
            <xsl:text>print("Variable </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> has value ", </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> , " is ", type( </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> )) </xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="vByte">
        <xsl:value-of select="name"/>
        <xsl:text>=b'''</xsl:text>
        <xsl:value-of select="value"/>
        <xsl:text>'''</xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:if test="@show eq 'Y'">
            <xsl:text>print("Variable </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> has value ", </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> , " is ", type( </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> )) </xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="vMemoryView">
        <xsl:value-of select="name"/>
        <xsl:text>=memoryview(</xsl:text>
        <xsl:value-of select="byteArray"/>
        <xsl:text>)</xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:if test="@show eq 'Y'">
            <xsl:text>print("Variable </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> has value ", </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> , " is ", type( </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> )) </xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="vByteArray">
        <xsl:value-of select="name"/>
        <xsl:text>=bytearray(</xsl:text>
        <xsl:choose>
            <xsl:when test=" string-length(value) &gt; 0 ">
                <xsl:text>b'''</xsl:text>
                <xsl:value-of select="value"/>
                <xsl:text>'''</xsl:text>
            </xsl:when>
            <xsl:when test=" string-length(byteVar) &gt; 0">
                <xsl:value-of select="byteVar"/>
            </xsl:when>
        </xsl:choose>
        <xsl:text>)</xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:if test="@show eq 'Y'">
            <xsl:text>print("Variable </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> has value ", </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> , " is ", type( </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> )) </xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="vFloat">
        <xsl:value-of select="name"/>
        <xsl:text>=</xsl:text>
        <xsl:value-of select="value"/>
        <xsl:value-of select="$v_newline"/>
        <xsl:if test="@show eq 'Y'">
            <xsl:text>print("Variable </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> has value ", </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> , " is ", type( </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> )) </xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="vComplex">
        <xsl:value-of select="name"/>
        <xsl:text>=</xsl:text>
        <xsl:value-of select="value/real"/>
        <xsl:text>+</xsl:text>
        <xsl:value-of select="value/imagine"/>
        <xsl:text>j</xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:if test="@show eq 'Y'">
            <xsl:text>print("Variable </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> has value ", </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> , " is ", type( </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> )) </xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="vSet">
        <xsl:value-of select="name"/>
        <xsl:text>={</xsl:text>
        <xsl:for-each select="values/value">
            <xsl:if test="position() &gt; 1">
                <xsl:text> ,</xsl:text>
            </xsl:if>
            <xsl:value-of select="."/>
        </xsl:for-each>
        <xsl:text>}</xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:if test="@show eq 'Y'">
            <xsl:text>print("Variable </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> has value ", </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> , " is ", type( </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> )) </xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="vList">
        <xsl:value-of select="name"/>
        <xsl:text>=[</xsl:text>
        <xsl:for-each select="values/value">
            <xsl:if test="position() &gt; 1">
                <xsl:text> ,</xsl:text>
            </xsl:if>
            <xsl:value-of select="."/>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:if test="@show eq 'Y'">
            <xsl:text>print("Variable </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> has value ", </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> , " is ", type( </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> )) </xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="vTuple">
        <xsl:value-of select="name"/>
        <xsl:text>=(</xsl:text>
        <xsl:for-each select="values/value">
            <xsl:if test="position() &gt; 1">
                <xsl:text> ,</xsl:text>
            </xsl:if>
            <xsl:value-of select="."/>
        </xsl:for-each>
        <xsl:text>)</xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:if test="@show eq 'Y'">
            <xsl:text>print("Variable </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> has value ", </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> , " is ", type( </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> )) </xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="vDictionary">
        <xsl:value-of select="name"/>
        <xsl:text>={</xsl:text>
        <xsl:for-each select="keys/key">
            <xsl:if test="position() &gt; 1">
                <xsl:text> ,</xsl:text>
            </xsl:if>
            <xsl:value-of select="name"/>
            <xsl:text>:</xsl:text>
            <xsl:value-of select="value"/>
        </xsl:for-each>
        <xsl:text>}</xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:if test="@show eq 'Y'">
            <xsl:text>print("Variable </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> has value ", </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> , " is ", type( </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> )) </xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="vString">
        <xsl:value-of select="name"/>
        <xsl:text>=</xsl:text>
        <xsl:choose>
            <xsl:when test=" quote eq 'single'">
                <xsl:text>'</xsl:text>
            </xsl:when>
            <xsl:when test=" quote eq 'double'">
                <xsl:text>"</xsl:text>
            </xsl:when>
            <xsl:when test=" quote eq 'triple'">
                <xsl:text>'''</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:value-of select="value"/>
        <xsl:choose>
            <xsl:when test=" quote eq 'single'">
                <xsl:text>'</xsl:text>
            </xsl:when>
            <xsl:when test=" quote eq 'double'">
                <xsl:text>"</xsl:text>
            </xsl:when>
            <xsl:when test=" quote eq 'triple'">
                <xsl:text>'''</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:value-of select="$v_newline"/>
        <xsl:if test="@show eq 'Y'">
            <xsl:text>print("Variable </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> has value ", </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> , " is ", type( </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text> )) </xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="block">
        <xsl:variable name="v_block_desc">
            <xsl:text># Block </xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:value-of select="$v_newline"/>
        </xsl:variable>
        <xsl:variable name="v_block_deco">
            <xsl:text>#</xsl:text>
            <xsl:value-of select="functx:repeat-string('B', string-length($v_block_desc))"/>
            <xsl:value-of select="$v_newline"/>
        </xsl:variable>
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="$v_block_deco"/>
        <xsl:value-of select="$v_block_desc"/>
        <xsl:value-of select="$v_block_deco"/>

        <xsl:for-each select="*">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="parameters">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>

        <xsl:for-each select="parameter">
            <xsl:value-of select="$v_indent_string"/>
            <xsl:if test="@local = 'Y'">
                <xsl:text>local </xsl:text>
            </xsl:if>
            <xsl:value-of select="@name"/>
            <xsl:text>=${</xsl:text>
            <xsl:value-of select="position()"/>
            <xsl:text>}</xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:for-each>

        <xsl:value-of select="$v_newline"/>
        <xsl:for-each select="parameter">
            <xsl:value-of select="$v_indent_string"/>
            <xsl:text>: ${</xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text>:="</xsl:text>
            <xsl:value-of select="@default"/>
            <xsl:text>"}</xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:for-each>

    </xsl:template>

    <xsl:template match="pipe">
        <xsl:text> | </xsl:text>
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="source">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>. </xsl:text>
        <xsl:value-of select="."/>

        <xsl:if test="string-length(@log) &gt; 0">
            <xsl:choose>
                <xsl:when test="@display = 'yes'">
                    <xsl:text> | tee </xsl:text>
                    <xsl:if test="@append = 'yes'">
                        <xsl:text>-a </xsl:text>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> &gt;</xsl:text>
                    <xsl:if test="@append = 'yes'">
                        <xsl:text>&gt;</xsl:text>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:value-of select="@log"/>
        </xsl:if>
        <xsl:value-of select="$v_newline"/>
    </xsl:template>


    <xsl:template match="block_desc">
        <xsl:variable name="v_block_desc">
            <xsl:text># </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text>: </xsl:text>
            <xsl:value-of select="desc"/>
            <xsl:value-of select="$v_newline"/>
        </xsl:variable>
        <xsl:variable name="v_block_deco">
            <xsl:text>#</xsl:text>
            <xsl:value-of select="functx:repeat-string('B', string-length($v_block_desc))"/>
            <xsl:value-of select="$v_newline"/>
        </xsl:variable>
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="$v_block_deco"/>
        <xsl:value-of select="$v_block_desc"/>
        <xsl:value-of select="$v_block_deco"/>
    </xsl:template>
    <xsl:template match="header">
        <xsl:variable name="v_desc">
            <xsl:text># </xsl:text>
            <xsl:value-of select="../@name"/>
            <xsl:value-of select="$v_newline"/>
            <xsl:text><![CDATA[<<COMMENT]]></xsl:text>
            <xsl:value-of select="$v_newline"/>
            <xsl:value-of select="desc"/>
            <xsl:value-of select="$v_newline"/>
            <xsl:text>COMMENT</xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:variable>

        <xsl:if test="string-length(shebang) &gt; 0">
            <xsl:text>#!</xsl:text>
            <xsl:value-of select="shebang"/>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>
        <xsl:value-of select="functx:repeat-string('#', 80)"/>
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="$v_desc"/>
        <xsl:value-of select="functx:repeat-string('#', 80)"/>
        <xsl:value-of select="$v_newline"/>
    </xsl:template>
    <xsl:template match="cat_file">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>

        <xsl:variable name="v_echo_cat">
            <xsl:value-of select="$v_indent_string"/>
            <xsl:text>echo "#CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"</xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:variable>

        <xsl:value-of select="$v_echo_cat"/>

        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>echo Begining of file: </xsl:text>
        <xsl:value-of select="."/>
        <xsl:value-of select="$v_newline"/>

        <xsl:value-of select="$v_echo_cat"/>

        <xsl:value-of select="$v_indent_string"/>

        <xsl:choose>
            <xsl:when test="@variable_expansion = 'yes'">
                <xsl:text><![CDATA[echo "cat << Variable_Expansion" > /tmp/cat_$$.tmp]]></xsl:text>
                <xsl:value-of select="$v_newline"/>
                <xsl:text>cat </xsl:text>
                <xsl:value-of select="."/>
                <xsl:text><![CDATA[>>/tmp/cat_$$.tmp]]></xsl:text>
                <xsl:value-of select="$v_newline"/>
                <xsl:text><![CDATA[echo "Variable_Expansion" >>/tmp/cat_$$.tmp]]></xsl:text>
                <xsl:value-of select="$v_newline"/>
                <xsl:text>. /tmp/cat_$$.tmp</xsl:text>
                <xsl:if test="string-length(@pipe) &gt; 0">
                    <xsl:text>|</xsl:text>
                    <xsl:value-of select="@pipe"/>
                </xsl:if>
                <xsl:value-of select="$v_newline"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>cat </xsl:text>
                <xsl:value-of select="."/>
                <xsl:if test="string-length(@pipe) &gt; 0">
                    <xsl:text>|</xsl:text>
                    <xsl:value-of select="@pipe"/>
                </xsl:if>
                <xsl:value-of select="$v_newline"/>
            </xsl:otherwise>
        </xsl:choose>


        <xsl:value-of select="$v_echo_cat"/>

        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>echo End of file: </xsl:text>
        <xsl:value-of select="."/>
        <xsl:value-of select="$v_newline"/>

        <xsl:value-of select="$v_echo_cat"/>
    </xsl:template>
    <xsl:template match="variable_input">
        <xsl:variable name="v_input_comment">
            <xsl:text># input variable</xsl:text>
            <xsl:value-of select="name"/>
            <xsl:value-of select="$v_newline"/>
        </xsl:variable>
        <xsl:value-of select="$v_input_comment"/>
        <xsl:text>#</xsl:text>
        <xsl:value-of select="functx:repeat-string('I', string-length($v_input_comment))"/>
        <xsl:value-of select="$v_newline"/>

        <xsl:if test="clear_definition = 'yes'">
            <xsl:text>unset </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>

        <xsl:value-of select="name"/>
        <xsl:text>=${</xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>:-"</xsl:text>
        <xsl:value-of select="default"/>
        <xsl:text>"}</xsl:text>
        <xsl:value-of select="$v_newline"/>

        <xsl:text>echo "Please type to Accept new value for</xsl:text>
        <xsl:value-of select="input_prompt"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>(default ${</xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>}):"</xsl:text>
        <xsl:value-of select="$v_newline"/>

        <xsl:text>read input</xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:if test="export = 'yes'">
            <xsl:text>export </xsl:text>
        </xsl:if>
        <xsl:value-of select="name"/>
        <xsl:text>=${input</xsl:text>
        <xsl:text>:-$</xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>}</xsl:text>
        <xsl:value-of select="$v_newline"/>
    </xsl:template>
    <xsl:template match="while_block">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>while </xsl:text>
        <xsl:apply-templates select="test[1]"/>
        <xsl:value-of select="$v_newline"/>
        <xsl:for-each select="*[name() != 'test']">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>done</xsl:text>
        <xsl:value-of select="$v_newline"/>
    </xsl:template>
    <xsl:template match="confirm_or_cancel">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>
        <xsl:variable name="v_confirm_cancel_string">
            <xsl:value-of select="$v_indent_string"/>
            <xsl:text>echo "</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text> type RETURN to continue or Ctrl+C to exit:"</xsl:text>
            <xsl:value-of select="$v_newline"/>
        </xsl:variable>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>echo #</xsl:text>
        <xsl:value-of select="functx:repeat-string('A', string-length($v_confirm_cancel_string))"/>
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="$v_confirm_cancel_string"/>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>read PPPP</xsl:text>
        <xsl:value-of select="$v_newline"/>
    </xsl:template>
    <xsl:template match="cd">
        <xsl:variable name="v_cd_cmd">
            <xsl:text>cd </xsl:text>
            <xsl:value-of select="."/>
            <xsl:value-of select="$v_newline"/>
        </xsl:variable>
        <xsl:text>#</xsl:text>
        <xsl:value-of select="functx:repeat-string('D', string-length($v_cd_cmd))"/>
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="$v_cd_cmd"/>
    </xsl:template>
    <xsl:template match="mkdir">
        <xsl:variable name="v_mkdir_cmd">
            <xsl:text>mkdir -p </xsl:text>
            <xsl:value-of select="."/>
            <xsl:value-of select="$v_newline"/>
        </xsl:variable>
        <xsl:text>#</xsl:text>
        <xsl:value-of select="functx:repeat-string('D', string-length($v_mkdir_cmd))"/>
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="$v_mkdir_cmd"/>
    </xsl:template>
    <xsl:template match="cat_here">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:text># </xsl:text>
        <xsl:value-of select="functx:pad-string-to-length(@desc, '!', 80)"/>
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>cat &lt;&lt; </xsl:text>
        <xsl:if test="@quote = 'yes'">
            <xsl:text>'</xsl:text>
        </xsl:if>
        <xsl:value-of select="@eof"/>
        <xsl:if test="@quote = 'yes'">
            <xsl:text>'</xsl:text>
        </xsl:if>
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="."/>
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="@eof"/>
        <xsl:value-of select="$v_newline"/>
    </xsl:template>
    <xsl:template match="confirm_yes_or_cancel">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>
        <xsl:variable name="v_confirm_yes_or_cancel">
            <xsl:value-of select="."/>
            <xsl:text> ---- Confirm with YeS(default n):</xsl:text>
        </xsl:variable>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>echo "</xsl:text>
        <xsl:value-of
            select="functx:pad-string-to-length('------ Confirm ------', 'YeS or n : ', string-length($v_confirm_yes_or_cancel))"/>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>echo "</xsl:text>
        <xsl:value-of select="$v_confirm_yes_or_cancel"/>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>confirm=n</xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>read input</xsl:text>
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>confirm=${input:-$confirm}</xsl:text>
        <xsl:value-of select="$v_newline"/>
    </xsl:template>
    <xsl:template match="full_code">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="internal_run_sql_file">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>
        <xsl:value-of select="$v_indent_string"/>
        <xsl:text>sqlplus / as sysdba @</xsl:text>
        <xsl:value-of select="."/>
        <xsl:value-of select="$v_newline"/>
    </xsl:template>

    <xsl:template match="run_here">
        <xsl:variable name="v_indent_string">
            <xsl:call-template name="get_indent"/>
        </xsl:variable>


        <xsl:if test="@cat_run_code != 'no'">
            <xsl:value-of select="$v_indent_string"/>
            <xsl:text>cat </xsl:text>
            <xsl:text> &lt;&lt; </xsl:text>
            <xsl:if test="@quote = 'yes'">
                <xsl:text>'</xsl:text>
            </xsl:if>
            <xsl:value-of select="@eof"/>
            <xsl:if test="@quote = 'yes'">
                <xsl:text>'</xsl:text>
            </xsl:if>
            <xsl:value-of select="$v_newline"/>
            <xsl:value-of select="."/>
            <xsl:value-of select="$v_newline"/>
            <xsl:value-of select="@eof"/>
            <xsl:value-of select="$v_newline"/>
        </xsl:if>

        <xsl:value-of select="$v_indent_string"/>
        <xsl:text># </xsl:text>
        <xsl:value-of select="functx:pad-string-to-length(@desc, '!', 80)"/>
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="$v_indent_string"/>

        <xsl:if test="@nohup = 'yes'">
            <xsl:text>nohup </xsl:text>
        </xsl:if>
        <xsl:value-of select="@run_cmd"/>
        <xsl:text> &lt;&lt; </xsl:text>
        <xsl:if test="@quote = 'yes'">
            <xsl:text>'</xsl:text>
        </xsl:if>
        <xsl:value-of select="@eof"/>
        <xsl:if test="@quote = 'yes'">
            <xsl:text>'</xsl:text>
        </xsl:if>
        <xsl:if test="string-length(@log) &gt; 0">
            <xsl:choose>
                <xsl:when test="@display = 'yes'">
                    <xsl:text> | tee </xsl:text>
                    <xsl:if test="@append = 'yes'">
                        <xsl:text>-a </xsl:text>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> &gt;</xsl:text>
                    <xsl:if test="@append = 'yes'">
                        <xsl:text>&gt;</xsl:text>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="@log"/>
        </xsl:if>

        <xsl:if test="@nohup = 'yes'">
            <xsl:text> 2&gt;&amp;1 &amp;</xsl:text>
        </xsl:if>

        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="."/>
        <xsl:value-of select="$v_newline"/>
        <xsl:value-of select="@eof"/>
        <xsl:value-of select="$v_newline"/>
    </xsl:template>
</xsl:stylesheet>
