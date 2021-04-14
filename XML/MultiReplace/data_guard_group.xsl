<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:functx="http://www.functx.com"
    exclude-result-prefixes="#all" version="2.0">

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

    <xsl:output method="xml"/>

    <xsl:variable name="v_newline">
        <xsl:text>&#xa;</xsl:text>
    </xsl:variable>

    <xsl:variable name="c_whole">
        <xsl:copy-of select="/data_guard"/>
    </xsl:variable>

    <xsl:variable name="v_configuration_name">
        <xsl:value-of select="/data_guard/@configuration_name"/>
    </xsl:variable>

    <xsl:variable name="v_configuration_tns">
        <xsl:text>output/</xsl:text>
        <xsl:value-of select="$v_configuration_name"/>
        <xsl:text>_tns.txt</xsl:text>
    </xsl:variable>

    <xsl:variable name="v_ssh_private">
        <xsl:value-of select="/data_guard/@ssh_private"/>
    </xsl:variable>

    <xsl:variable name="v_tns_template">
        <xsl:text><![CDATA[${DG_PRIMARY_SRVCTL_NAME} =
  (DESCRIPTION =
     (FAILOVER = ON)
     (ADDRESS_LIST =
          (ADDRESS = (PROTOCOL = TCP)(HOST = ${DG_PRIMARY_NODE_1_IP})(PORT = ${DG_PRIMARY_PORT}))
          (ADDRESS = (PROTOCOL = TCP)(HOST = ${DG_PRIMARY_NODE_2_IP})(PORT = ${DG_PRIMARY_PORT}))
          (ADDRESS = (PROTOCOL = TCP)(HOST = ${DG_PRIMARY_SCAN_IP1})(PORT = ${DG_PRIMARY_PORT}))
          (ADDRESS = (PROTOCOL = TCP)(HOST = ${DG_PRIMARY_SCAN_IP2})(PORT = ${DG_PRIMARY_PORT}))
          (ADDRESS = (PROTOCOL = TCP)(HOST = ${DG_PRIMARY_SCAN_IP3})(PORT = ${DG_PRIMARY_PORT}))
     )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${DG_PRIMARY_SERVICE_NAME})
      (FAILOVER_MODE =
        (TYPE = select)
        (METHOD = basic)
      )
    )
  )
]]></xsl:text>
    </xsl:variable>
    <xsl:variable name="fr"
        select="
            ('\$\{DG_PRIMARY_SRVCTL_NAME\}',
            '\$\{DG_PRIMARY_SERVICE_NAME\}',
            '\$\{DG_PRIMARY_PORT\}',
            '\$\{DG_PRIMARY_NODE_1_IP\}',
            '\$\{DG_PRIMARY_NODE_2_IP\}',
            '\$\{DG_PRIMARY_SCAN_IP1\}',
            '\$\{DG_PRIMARY_SCAN_IP2\}',
            '\$\{DG_PRIMARY_SCAN_IP3\}')
            "/>

    <xsl:template match="/">
        <xsl:result-document href="{$v_configuration_tns}" method="text">
            <xsl:for-each select="//cdbs/cdb[string-length(@role) &gt; 0]">
                <xsl:variable name="v_srvctl_name" select="srvctl_name"/>
                <xsl:variable name="v_service_name" select="service_name"/>
                <xsl:variable name="v_port" select="port"/>
                <xsl:variable name="v_cluster" select="cluster"/>
                <xsl:variable name="c_cluster"
                    select="//clusters/cluster[cluster_name = $v_cluster]"/>
                <xsl:variable name="v_ip1" select="$c_cluster/node_1_ip"/>
                <xsl:variable name="v_ip2" select="$c_cluster/node_2_ip"/>
                <xsl:variable name="v_sip1" select="$c_cluster/scan_ip1"/>
                <xsl:variable name="v_sip2" select="$c_cluster/scan_ip2"/>
                <xsl:variable name="v_sip3" select="$c_cluster/scan_ip3"/>

                <xsl:variable name="to"
                    select="
                        ($v_srvctl_name,
                        $v_service_name,
                        $v_port,
                        $v_ip1,
                        $v_ip2,
                        $v_sip1,
                        $v_sip2,
                        $v_sip3
                        )
                        "/>

                <xsl:value-of select="functx:replace-multi($v_tns_template, $fr, $to)"/>

            </xsl:for-each>
        </xsl:result-document>
        <xsl:for-each select="//pairs/pair">
            <xsl:variable name="v_pair_file">
                <xsl:text>output/</xsl:text>
                <xsl:value-of select="file"/>
            </xsl:variable>
            
            <xsl:variable name="v_pair_name" select="substring-before($v_pair_file, '.')"/>
            <xsl:variable name="c_pair">
                <xsl:copy-of select="."/>
            </xsl:variable>
            <xsl:result-document href="{$v_pair_file}" method="xml" indent="yes">
                <xsl:processing-instruction name="xml-stylesheet">
                    <xsl:text>type="text/xsl" href="data_guard_pair.xsl"</xsl:text>
                </xsl:processing-instruction>
                <data_guard_pair>
                    <xsl:attribute name="name" select="$v_pair_name"/>
                    <xsl:attribute name="configuration_name" select="$v_configuration_name"/>
                    <xsl:attribute name="ssh_private" select="$v_ssh_private"/>
                    <clusters>
                        <xsl:for-each select="$c_pair//cluster">
                            <xsl:variable name="v_cluster_name" select="."/>
                            <xsl:copy-of select="$c_whole//cluster[cluster_name = $v_cluster_name]"
                            />
                        </xsl:for-each>
                    </clusters>
                    <xsl:copy-of select="$c_whole//users"/>
                    <cdbs>
                        <xsl:for-each select="$c_pair//cdb">
                            <xsl:variable name="v_cdb" select="."/>
                            <xsl:copy-of select="$c_whole//cdb[srvctl_name = $v_cdb]"/>
                        </xsl:for-each>
                    </cdbs>
                </data_guard_pair>
            </xsl:result-document>

        </xsl:for-each>

    </xsl:template>

</xsl:stylesheet>
