<?xml version="1.0" encoding="UTF-8"?>
<!--
 * Copyright (c) 2001 World Wide Web Consortium,
 * (Massachusetts Institute of Technology, Institut National de
 * Recherche en Informatique et en Automatique, Keio University). All
 * Rights Reserved. This program is distributed under the W3C's Software
 * Intellectual Property License. This program is distributed in the
 * hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.
 * See W3C License http://www.w3.org/Consortium/Legal/ for more details.
-->

<!--   
This transforms generates an XML DTD for a DOM test definition
language from  an DOM specification.

DOM recommendations are defined in XML and the XML source for these
specifications is available within the .zip version of the specification.

For example, the DOM Level 1 .zip file, 
http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/DOM.zip 
contains a nested file, xml-source.zip, which contains an
XML file, wd-dom.xml which expresses the DOM recommendation
in XML.  (Note: most of the other .xml files are external 
entities expanded by one enclosing document).


Usage:

saxon -o dom1-test.dtd wd-dom.xml dom-to-dtd.xsl


-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:param name="schema-namespace">http://www.w3.org/2001/DOM-Test-Suite/Level-X</xsl:param>

	<!--   symbolic constant for schema namespace   -->
	<xsl:variable name="source" select="/spec/header/publoc/loc[1]/@href"/>
	<xsl:output method="text" indent="yes"/>

	<!--  interfaces defined in DOM recommendation  -->
	<xsl:variable name="interfaces" select="//interface"/>
	<!--  attributes defined in DOM recommendation  -->
	<xsl:variable name="attributes" select="//attribute"/>
	<!--  methods defined in DOM recommendation  -->
	<xsl:variable name="methods" select="//method"/>

	<!--  interfaces keyed by super class -->
	<xsl:key name="bysuper" match="//interface[@inherits]" use="@inherits"/>
	<!--  attributes keyed by name        -->
	<xsl:key name="attrByName" match="//attribute[@name]" use="@name"/>
	<!--  methods keyed by name           -->
	<xsl:key name="methodByName" match="//method[@name]" use="@name"/>
	<!--  attributes and methods keyed by name        -->
	<xsl:key name="featureByName" match="//*[(name()='attribute' or name()='method') and @name]" use="@name"/>


	<!--   match document root   -->
	<xsl:template match="/">
<xsl:text>
&lt;!--
 Copyright (c) 2001 World Wide Web Consortium,
 (Massachusetts Institute of Technology, Institut National de
 Recherche en Informatique et en Automatique, Keio University). All
 Rights Reserved. This program is distributed under the W3C's Software
 Intellectual Property License. This program is distributed in the
 hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 PURPOSE.
 See W3C License http://www.w3.org/Consortium/Legal/ for more details.

This schema was generated from </xsl:text><xsl:value-of select="$source"/><xsl:text> by dom-to-xsd.dtd.

--&gt;

&lt;!ENTITY % framework-assertion "assertTrue|assertFalse|assertNull|assertNotNull|assertEquals|assertNotEquals|assertSame|assertInstanceOf|assertSize|assertEventCount"&gt;

&lt;!ENTITY % framework-statement "assign|increment|decrement|append|plus|subtract|multiply|divide|load|implementation|hasFeature|if|while|for-each|comment|EventMonitor.setUserObj|EventMonitor.getAtEvents|EventMonitor.getCaptureEvents|EventMonitor.getBubbleEvents|EventMonitor.getAllEvents|wait"&gt;

&lt;!ENTITY % implementation-condition "validating|coalescing|isExpandingEntityReferences|ignoringElementContentWhitespace|ignoringComments|namespaceAware|hasFeature|signed|not"&gt;

&lt;!ENTITY % condition "same|equals|notEquals|less|lessOrEquals|greater|greaterOrEquals|isNull|notNull|and|or|xor|instanceOf|isTrue|isFalse|hasSize| %implementation-condition;"&gt;

&lt;!ENTITY % assertion "%framework-assertion;</xsl:text>
	<xsl:variable name="exceptions" select="//exception[@id]"/>
	<xsl:if test="$exceptions">
 		<xsl:text>| assert</xsl:text>
		<xsl:value-of select="$exceptions[1]/@name"/>
		<xsl:for-each select="$exceptions[position() &gt; 1]">
			<xsl:text>| assert</xsl:text>
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:if>
	<xsl:text>" &gt;
</xsl:text>


			<!--   produce fixed simpleType definitions    -->
			<xsl:call-template name="static-simpleTypes"/>
			<!--   produce simpleType definitions that depend on the source document  -->
			<xsl:call-template name="dynamic-simpleTypes"/>
			<!--   produce element definitions that depend on the source document    -->
			<xsl:call-template name="dynamic-elements"/>
			<!--   generate assertion elements that depend on the source document    -->
			<xsl:call-template name="dynamic-assertions"/>

			<!--   produce elements that correspond to DOM attributes   -->
			<xsl:call-template name="produce-properties"/>
			<!--   produce elements that correspond to DOM methods     -->
			<xsl:call-template name="produce-methods"/>

			<!--   produce fixed element definitions        -->			
			<xsl:call-template name="static-elements"/>
	</xsl:template>


	<!--    produce elements that correspond to DOM attributes    
			If the same attribute name is used in multiple contexts,
			for example, target is used both by Event and ProcessingInstruction,
			only one element will be created.  The interface attribute
			will be required to disambiguate.
	-->
    <xsl:template name="produce-properties">
			<!--   generate an schema element for each interface attribute    -->
			<xsl:for-each select="$attributes">
				<xsl:sort select="@name"/>

			  <!--  suppress creation of title element since it is also used
			          as metadata, hardcoded version that can do both appears
					  elsewhere   -->
			  <xsl:if test="@name != 'title'">

				<!--   Note: some DOM processors have had problems with current(),
				       so as a kludge, the current context is made an
					   explicit variable and used in place of current()   -->
				<xsl:variable name="current" select="."/>

				<!--  only the first entry creates an entry  -->
				<xsl:if test="not(preceding::attribute[@name=$current/@name]) and @name != 'implementation'">

					<!--  create an element whose tag name is the same as the attribute  -->
&lt;!ELEMENT <xsl:value-of select="@name"/> EMPTY&gt;
&lt;!ATTLIST <xsl:value-of select="@name"/><xsl:text>
    id ID #IMPLIED
	obj CDATA #REQUIRED
</xsl:text>
					<xsl:choose>
						<xsl:when test="@readonly='yes'">
							<xsl:text>    var CDATA #REQUIRED
</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>    var CDATA #IMPLIED
</xsl:text>
							<!--  produces a "value" attribute, 
							      the schema type is selected based on the attribute type   -->
							<xsl:call-template name="param-type">
								<xsl:with-param name="type" select="@type"/>
								<xsl:with-param name="paramName">value</xsl:with-param>
								<xsl:with-param name="use">#IMPLIED</xsl:with-param>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>

					<!--  collect all attributes with this name   -->
					<xsl:variable name="dups" select="key('featureByName',@name)"/>

							<!--  produce the "interface" attribute       -->
<xsl:text>    interface ( </xsl:text>
							<xsl:for-each select="$dups[1]">
								<xsl:value-of select="parent::interface/@name"/>
							</xsl:for-each>
							<xsl:for-each select="$dups[position() &gt; 1]">
								<xsl:text> | </xsl:text>
								<xsl:value-of select="parent::interface/@name"/>
							</xsl:for-each>
							<xsl:text> ) </xsl:text>
						<!--  choose whether interface is required based
						         on number of interfaces method is introduced by  -->
						<xsl:choose>
							<xsl:when test="count($dups) &gt; 1">
								<xsl:text>#REQUIRED</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>#IMPLIED</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					<xsl:text>&gt;</xsl:text>
				</xsl:if>
              </xsl:if>
			</xsl:for-each>
	</xsl:template>


	<!--   produce elements for all of the DOM methods.  Identically named
	       methods, for example, Document.getElementsByTagName and 
		   Element.getElementsByTag name will be represented by
		   one element.  Since these are much rarer than identically
		   named attributes and the function signatures are identical
		   for all known instances.  This template assumes that the
		   signature of the first instance is appropriate for all.
	-->
	<xsl:template name="produce-methods">

			<!--  produce an element for all methods  -->
			<xsl:for-each select="$methods[@name != 'hasFeature' and @name != 'handleEvent']">
				<xsl:sort select="@name"/>
				<xsl:variable name="name" select="@name"/>
				<xsl:variable name="current" select="."/>

				<!--   for only the first occurance of the name and the method
				               name wasn't also an attribute name
				               (TreeWalker defines firstChild, etc as methods   
				-->
				<xsl:if test="not(preceding::method[@name=$name]) and not(@name = $attributes/@name)">					
					<xsl:text>
&lt;!ELEMENT </xsl:text><xsl:value-of select="$name"/><xsl:text> EMPTY &gt;
&lt;!ATTLIST </xsl:text><xsl:value-of select="$name"/><xsl:text>
    id ID #REQUIRED
    obj CDATA #REQUIRED
</xsl:text>

					<!--  If the method has a (non-void) return value then
					      the var attribute is required to receive the return value  -->
					<xsl:if test="returns[@type!='void']">
						<xsl:text>    var CDATA #REQUIRED
</xsl:text>
					</xsl:if>

					<!--  for each parameter    -->
					<xsl:for-each select="parameters/param">
						<!--  need to check that all the types are consistent  -->
						<xsl:call-template name="param-type">
							<xsl:with-param name="type" select="@type"/>
							<xsl:with-param name="paramName" select="@name"/>
							<xsl:with-param name="use">#REQUIRED</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>

					<!--  produce interface attribute   -->
					<xsl:variable name="dups" select="key('methodByName',@name)"/>
					<xsl:text>    interface (</xsl:text>
					<xsl:for-each select="$dups[1]">
						<xsl:value-of select="parent::interface/@name"/>
					</xsl:for-each>
					<xsl:for-each select="$dups[position() &gt; 1]">
						<xsl:text>|</xsl:text>
						<xsl:value-of select="parent::interface/@name"/>
					</xsl:for-each>
					<xsl:text>)</xsl:text>

					<xsl:choose>
						<xsl:when test="count($dups) &gt; 1">
							<xsl:text> #REQUIRED
</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text> #IMPLIED
</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>&gt;

</xsl:text>
				</xsl:if>
			</xsl:for-each>
	</xsl:template>

	<!--  this template contains simple types that are indepenent
	      of the DOM recommendation.	
	-->
    <xsl:template name="static-simpleTypes">
   </xsl:template>

	<!--   this template generates any simple types
	       that are dependent on the source document.  Currently only
		   the allowable types for variables    -->
	<xsl:template name="dynamic-simpleTypes">
		<xsl:text>&lt;!ENTITY % variable-type "int|DOMString|List|Collection|EventMonitor</xsl:text>
					<xsl:for-each select="$interfaces">
						<xsl:sort select="@name"/>
						<xsl:text>|</xsl:text>
						<xsl:value-of select="@name"/>
					</xsl:for-each>
			<xsl:text>"&gt;
</xsl:text>
	</xsl:template>

	<!--   This template contains the elements that are 
	       independent of the source document.  Examples of these
		   elements are <test>, <var>, <assign>, etc.
	-->
    <xsl:template name="static-elements">


&lt;!ELEMENT test (metadata?,(%implementation-condition;)*,var*,(load|implementation),(%statement;)*) &gt;
&lt;!ATTLIST test 
   xmlns CDATA #FIXED "<xsl:value-of select="$schema-namespace"/>"
   id ID #IMPLIED
   targetURI CDATA #IMPLIED
   name CDATA #REQUIRED
   package CDATA #IMPLIED
&gt;

&lt;!ELEMENT package (metadata?, (test|suite)*)&gt;
&lt;!ATTLIST package
   xmlns CDATA #FIXED "<xsl:value-of select="$schema-namespace"/>"
	id ID #IMPLIED
&gt;

&lt;!ELEMENT suite (metadata?,(%implementation-condition;)*,(suite.member)*)&gt;
&lt;!ATTLIST suite
   xmlns CDATA #FIXED "<xsl:value-of select="$schema-namespace"/>"
   id ID #IMPLIED
   targetURI CDATA #REQUIRED
   name CDATA #REQUIRED
   package CDATA #IMPLIED
&gt;

&lt;!ELEMENT suite.member EMPTY&gt;
&lt;!ATTLIST suite.member
   href CDATA #REQUIRED
&gt;


&lt;!ELEMENT comment (#PCDATA)&gt;
&lt;!ATTLIST comment
	id ID #IMPLIED
&gt;

&lt;!ELEMENT wait EMPTY&gt;
&lt;!ATTLIST wait
	id ID #IMPLIED
	milliseconds CDATA #REQUIRED
&gt;

&lt;!ELEMENT append EMPTY&gt;
&lt;!ATTLIST append
	id ID #IMPLIED
	collection CDATA #REQUIRED
	obj CDATA #REQUIRED
&gt;

&lt;!ELEMENT assign ((%condition;)?)?&gt;
&lt;!ATTLIST assign
	id ID #IMPLIED
	var CDATA #REQUIRED
	value CDATA #IMPLIED
&gt;

&lt;!ELEMENT increment EMPTY&gt;
&lt;!ATTLIST increment
	id ID #IMPLIED
	var CDATA #REQUIRED
	value CDATA #REQUIRED
&gt;

&lt;!ELEMENT decrement EMPTY&gt;
&lt;!ATTLIST decrement
	id ID #IMPLIED
	var CDATA #REQUIRED
	value CDATA #REQUIRED
&gt;

&lt;!ELEMENT plus EMPTY&gt;
&lt;!ATTLIST plus
	id ID #IMPLIED
	var CDATA #REQUIRED
	op1 CDATA #REQUIRED
	op2 CDATA #REQUIRED
&gt;

&lt;!ELEMENT subtract EMPTY&gt;
&lt;!ATTLIST subtract
	id ID #IMPLIED
	var CDATA #REQUIRED
	op1 CDATA #REQUIRED
	op2 CDATA #REQUIRED
&gt;

&lt;!ELEMENT multiply EMPTY&gt;
&lt;!ATTLIST multiply
	id ID #IMPLIED
	var CDATA #REQUIRED
	op1 CDATA #REQUIRED
	op2 CDATA #REQUIRED
&gt;

&lt;!ELEMENT divide EMPTY&gt;
&lt;!ATTLIST divide
	id ID #IMPLIED
	var CDATA #REQUIRED
	op1 CDATA #REQUIRED
	op2 CDATA #REQUIRED
&gt;

&lt;!ELEMENT var (member+ | handleEvent)?&gt;
&lt;!ATTLIST var
	id ID #IMPLIED
	name CDATA #REQUIRED
	type (%variable-type;) #REQUIRED
	value CDATA #IMPLIED
&gt;

&lt;!ELEMENT member (#PCDATA)&gt;

&lt;!ELEMENT handleEvent (var*, (%statement;)+)>
&lt;!ATTLIST handleEvent
	return CDATA #IMPLIED
&gt;

&lt;!ELEMENT load EMPTY&gt;
&lt;!ATTLIST load
	var CDATA #REQUIRED
	href CDATA #REQUIRED
	willBeModified CDATA #REQUIRED
	documentElementTagName CDATA #IMPLIED
&gt;

&lt;!ELEMENT implementation EMPTY&gt;
&lt;!ATTLIST implementation
	var CDATA #REQUIRED
	obj CDATA #IMPLIED
&gt;


&lt;!--  since title is used both as a metadata element and
            a read-write attribute, it is hard coded here   --&gt;
&lt;!ELEMENT title (#PCDATA)&gt;
&lt;!ATTLIST title
    id ID #IMPLIED
	obj CDATA #IMPLIED					
    var CDATA #IMPLIED
	value CDATA #IMPLIED
    interface CDATA #IMPLIED
&gt;


&lt;!ELEMENT metadata (metadata | title | creator | subject | description | contributor | date | source | relation)*&gt;
&lt;!ATTLIST metadata
	id ID #IMPLIED
	about CDATA #IMPLIED
&gt;

&lt;!ELEMENT creator (#PCDATA)&gt;
&lt;!ATTLIST creator
	id ID #IMPLIED
	resource CDATA #IMPLIED
	type CDATA #IMPLIED
&gt;

&lt;!ELEMENT subject (#PCDATA)&gt;
&lt;!ATTLIST subject
	id ID #IMPLIED
	resource CDATA #IMPLIED
	type CDATA #IMPLIED
&gt;

&lt;!ELEMENT description (#PCDATA)&gt;
&lt;!ATTLIST description
	id ID #IMPLIED
	resource CDATA #IMPLIED
	type CDATA #IMPLIED
&gt;

&lt;!ELEMENT contributor (#PCDATA)&gt;
&lt;!ATTLIST contributor
	id ID #IMPLIED
	resource CDATA #IMPLIED
	type CDATA #IMPLIED
&gt;

&lt;!ELEMENT date (#PCDATA)&gt;
&lt;!ATTLIST date
	id ID #IMPLIED
	qualifier (created | valid | available | issued | modified) #REQUIRED
&gt;

&lt;!ELEMENT source (#PCDATA)&gt;
&lt;!ATTLIST source
	id ID #IMPLIED
	resource CDATA #IMPLIED
	type CDATA #IMPLIED
&gt;

&lt;!ELEMENT relation (#PCDATA)&gt;
&lt;!ATTLIST relation
	id ID #IMPLIED
	resource CDATA #IMPLIED
	type CDATA #IMPLIED
	qualifier (isVersionOf | hasVersion | isReplacedBy | isRequiredBy | requires | isPartOf | hasPart | isReferenceBy | references) #REQUIRED
&gt;
					
&lt;!ELEMENT assertTrue ((%condition;),(%statement;)*)&gt;
&lt;!ATTLIST assertTrue
	id ID #REQUIRED
	actual CDATA #IMPLIED
&gt;
							
&lt;!ELEMENT assertFalse ((%condition;),(%statement;)*)&gt;
&lt;!ATTLIST assertFalse
	id ID #REQUIRED
	actual CDATA #IMPLIED
&gt;

&lt;!ELEMENT assertNull (metadata?, (%statement;)*)&gt;
&lt;!ATTLIST assertNull
	actual CDATA #REQUIRED
	id ID #REQUIRED
&gt;

&lt;!ELEMENT assertNotNull (metadata?, (%statement;)*)&gt;
&lt;!ATTLIST assertNotNull
	actual CDATA #REQUIRED
	id ID #REQUIRED
&gt;

&lt;!ELEMENT assertSame (metadata?, (%statement;)*)&gt;
&lt;!ATTLIST assertSame
	actual CDATA #REQUIRED
	expected CDATA #REQUIRED
	id ID #REQUIRED
&gt;

&lt;!ELEMENT assertInstanceOf (metadata?, (%statement;)*)&gt;
&lt;!ATTLIST assertInstanceOf
	obj CDATA #REQUIRED
	type (%variable-type;) #REQUIRED
	id ID #REQUIRED
&gt;

&lt;!ELEMENT assertSize (metadata?, (%statement;)*)&gt;
&lt;!ATTLIST assertSize
	collection CDATA #REQUIRED
	size CDATA #REQUIRED
	id ID #REQUIRED
&gt;

&lt;!ELEMENT assertEquals (metadata?, (%statement;)*)&gt;
&lt;!ATTLIST assertEquals
	actual CDATA #REQUIRED
	expected CDATA #REQUIRED
	id ID #REQUIRED
	ignoreCase CDATA #REQUIRED
&gt;

&lt;!ELEMENT assertNotEquals (metadata?, (%statement;)*)&gt;
&lt;!ATTLIST assertNotEquals
	actual CDATA #REQUIRED
	expected CDATA #REQUIRED
	id ID #REQUIRED
	ignoreCase CDATA #REQUIRED
&gt;

&lt;!ELEMENT assertEventCount (metadata?, (%statement;)*)&gt;
&lt;!ATTLIST assertEventCount
	atCount CDATA #IMPLIED
	captureCount CDATA #IMPLIED
	bubbleCount CDATA #IMPLIED
	totalCount CDATA #IMPLIED
	monitor CDATA #REQUIRED
	id ID #REQUIRED
&gt;

&lt;!ELEMENT same EMPTY&gt;
&lt;!ATTLIST same
	id ID #IMPLIED
	actual CDATA #REQUIRED
	expected CDATA #REQUIRED
&gt;

&lt;!ELEMENT equals EMPTY&gt;
&lt;!ATTLIST equals
	id ID #IMPLIED
	actual CDATA #REQUIRED
	expected CDATA #REQUIRED
	ignoreCase (true|false) "false"
&gt;

&lt;!ELEMENT notEquals EMPTY&gt;
&lt;!ATTLIST equals
	id ID #IMPLIED
	actual CDATA #REQUIRED
	expected CDATA #REQUIRED
	ignoreCase (true|false) "false"
&gt;

&lt;!ELEMENT less EMPTY&gt;
&lt;!ATTLIST less
	id ID #IMPLIED
	actual CDATA #REQUIRED
	expected CDATA #REQUIRED
&gt;

&lt;!ELEMENT lessOrEquals EMPTY&gt;
&lt;!ATTLIST lessOrEquals
	id ID #IMPLIED
	actual CDATA #REQUIRED
	expected CDATA #REQUIRED
&gt;

&lt;!ELEMENT greater EMPTY&gt;
&lt;!ATTLIST greater
	id ID #IMPLIED
	actual CDATA #REQUIRED
	expected CDATA #REQUIRED
&gt;

&lt;!ELEMENT greaterOrEquals EMPTY&gt;
&lt;!ATTLIST greaterOrEquals
	id ID #IMPLIED
	actual CDATA #REQUIRED
	expected CDATA #REQUIRED
&gt;

&lt;!ELEMENT isNull EMPTY&gt;
&lt;!ATTLIST isNull
	id ID #IMPLIED
	obj CDATA #REQUIRED
&gt;

&lt;!ELEMENT notNull EMPTY&gt;
&lt;!ATTLIST notNull
	id ID #IMPLIED
	obj CDATA #REQUIRED
&gt;

&lt;!ELEMENT instanceOf EMPTY&gt;
&lt;!ATTLIST instanceOf
	id ID #IMPLIED
	obj CDATA #REQUIRED
	type (%variable-type;) #REQUIRED
&gt;

&lt;!ELEMENT hasSize EMPTY&gt;
&lt;!ATTLIST hasSize
	id ID #IMPLIED
	obj CDATA #REQUIRED
	expected CDATA #REQUIRED
&gt;

&lt;!ELEMENT validating EMPTY&gt;
&lt;!ATTLIST validating
	id ID #IMPLIED
&gt;

&lt;!ELEMENT coalescing EMPTY&gt;
&lt;!ATTLIST coalescing
	id ID #IMPLIED
&gt;

&lt;!ELEMENT isExpandingEntityReferences EMPTY&gt;
&lt;!ATTLIST isExpandingEntityReferences
	id ID #IMPLIED
&gt;


&lt;!ELEMENT namespaceAware EMPTY&gt;
&lt;!ATTLIST namespaceAware
	id ID #IMPLIED
&gt;

&lt;!ELEMENT ignoringElementContentWhitespace EMPTY&gt;
&lt;!ATTLIST ignoringElementContentWhitespace
	id ID #IMPLIED
&gt;

&lt;!ELEMENT ignoringComments EMPTY&gt;
&lt;!ATTLIST ignoringComments
	id ID #IMPLIED
&gt;

&lt;!ELEMENT signed EMPTY&gt;
&lt;!ATTLIST signed
	id ID #IMPLIED
&gt;

&lt;!ELEMENT hasFeature EMPTY&gt;
&lt;!ATTLIST hasFeature
	id ID #IMPLIED
	feature (XML | Core | Events | MutationEvents | Traversal | Range) #REQUIRED
	version (1.0 | 2.0 | 3.0) #IMPLIED
	var CDATA #IMPLIED
	obj CDATA #IMPLIED
&gt;

&lt;!ELEMENT not ((%condition;))&gt;
&lt;!ATTLIST not
	id ID #IMPLIED
&gt;

&lt;!ELEMENT isTrue EMPTY&gt;
&lt;!ATTLIST isTrue
	id ID #IMPLIED
	value CDATA #REQUIRED
&gt;

&lt;!ELEMENT isFalse EMPTY&gt;
&lt;!ATTLIST isFalse
	id ID #IMPLIED
	value CDATA #REQUIRED
&gt;

&lt;!ELEMENT or ((%condition;),(%condition;)+)&gt;
&lt;!ATTLIST or
	id ID #IMPLIED
&gt;

&lt;!ELEMENT and ((%condition;),(%condition;)+)&gt;
&lt;!ATTLIST and
	id ID #IMPLIED
&gt;

&lt;!ELEMENT xor ((%condition;),(%condition;))&gt;
&lt;!ATTLIST xor
	id ID #IMPLIED
&gt;

&lt;!ELEMENT else ((%statement;)+)&gt;
&lt;!ATTLIST else
	id ID #IMPLIED
&gt;

&lt;!ELEMENT if ((%condition;), (%statement;)+, else?)&gt;
&lt;!ATTLIST if
	id ID #IMPLIED
&gt;

&lt;!ELEMENT while ((%condition;),(%statement;)+)&gt;
&lt;!ATTLIST while
	id ID #IMPLIED
&gt;

&lt;!ELEMENT for-each ((%statement;)*)&gt;
&lt;!ATTLIST for-each
	collection CDATA #REQUIRED
	member CDATA #REQUIRED
	id ID #IMPLIED
&gt;

&lt;!ELEMENT EventMonitor.setUserObj EMPTY&gt;
&lt;!ATTLIST EventMonitor.setUserObj
	id ID #IMPLIED
	obj CDATA #REQUIRED
	userObj CDATA #REQUIRED
&gt;

&lt;!ELEMENT EventMonitor.getAtEvents EMPTY&gt;
&lt;!ATTLIST EventMonitor.getAtEvents
	id ID #IMPLIED
	monitor CDATA #REQUIRED
	var CDATA #REQUIRED
&gt;

&lt;!ELEMENT EventMonitor.getBubbleEvents EMPTY&gt;
&lt;!ATTLIST EventMonitor.getBubbleEvents
	id ID #IMPLIED
	monitor CDATA #REQUIRED
	var CDATA #REQUIRED
&gt;

&lt;!ELEMENT EventMonitor.getCaptureEvents EMPTY&gt;
&lt;!ATTLIST EventMonitor.getCaptureEvents
	id ID #IMPLIED
	monitor CDATA #REQUIRED
	var CDATA #REQUIRED
&gt;


&lt;!ELEMENT EventMonitor.getAllEvents EMPTY&gt;
&lt;!ATTLIST EventMonitor.getAllEvents
	id ID #IMPLIED
	monitor CDATA #REQUIRED
	var CDATA #REQUIRED
&gt;

	</xsl:template>

	<!--   This template produces assertion elements for each
	       defined exception type   -->
    <xsl:template name="dynamic-assertions">

		<!--  checking for non-null id attributes gets exception definitions
		         not uses  -->
		<xsl:for-each select="//exception[@id]">		
			<xsl:variable name="exception" select="@name"/>
			<xsl:text>&lt;!ELEMENT assert</xsl:text>
			<xsl:value-of select="@name"/>
			<xsl:text> (metadata?,(</xsl:text>
			<xsl:variable name="codes" select="following-sibling::group[1]/constant"/>
			<xsl:value-of select="$codes[1]/@name"/>
			<xsl:for-each select="$codes[position() &gt; 1]">
				<xsl:text>|</xsl:text>
				<xsl:value-of select="@name"/>
			</xsl:for-each>
			<xsl:text>))&gt;
&lt;!ATTLIST assert</xsl:text>
			<xsl:value-of select="@name"/>
			<xsl:text> id ID #REQUIRED&gt;
</xsl:text>

			<!--  produce elements for each of the defined codes for
			        the exception.  The content model of these
					elements are the methods and attributes that
					raise that specific code.
			-->
			<xsl:for-each select="following-sibling::group[1]/constant">
				<xsl:text>&lt;!ELEMENT </xsl:text>
				<xsl:value-of select="@name"/>
				<xsl:variable name="code" select="@name"/>
				<xsl:variable name="code-colon"><xsl:value-of select="@name"/>:</xsl:variable>
				<xsl:variable name="getraises" select="$attributes/getraises/exception[@name=$exception and contains(string(.),$code-colon)]"/>
				<xsl:variable name="setraises" select="$attributes/setraises/exception[@name=$exception and contains(string(.),$code-colon)]"/>
				<xsl:variable name="methodraises" select="$methods/raises/exception[@name=$exception and contains(string(.),$code-colon)]"/>
				<xsl:variable name="total" select="count($getraises) + count($setraises) + count($methodraises)"/>
				<xsl:choose>
					<xsl:when test="$total = 0">
						<xsl:text> EMPTY </xsl:text>
					</xsl:when>

					<xsl:when test="$total = 1">
						<xsl:text> ( </xsl:text>
						<xsl:for-each select="$getraises">
							<xsl:value-of select="ancestor::attribute/@name"/>
						</xsl:for-each>
						<xsl:for-each select="$setraises">
							<xsl:value-of select="ancestor::attribute/@name"/>
						</xsl:for-each>
						<xsl:for-each select="$methodraises">
							<xsl:value-of select="ancestor::method/@name"/>
						</xsl:for-each>
						<xsl:text> )
</xsl:text>
					</xsl:when>

					<xsl:when test="count($getraises) + count($setraises) = 0">
						<xsl:text> ( </xsl:text>
						<xsl:for-each select="$methodraises[1]">
							<xsl:value-of select="ancestor::method/@name"/>
						</xsl:for-each>
						<xsl:for-each select="$methodraises[position() &gt; 1]">
							<xsl:text> | </xsl:text>
							<xsl:value-of select="ancestor::method/@name"/>
						</xsl:for-each>
						<xsl:text> ) </xsl:text>
					</xsl:when>

					<xsl:when test="count($getraises) = 0">
						<xsl:text> ( </xsl:text>
						<xsl:for-each select="$setraises[1]">
							<xsl:value-of select="ancestor::attribute/@name"/>
						</xsl:for-each>
						<xsl:for-each select="$setraises[position() &gt; 1]">
							<xsl:text> | </xsl:text>
							<xsl:value-of select="ancestor::attribute/@name"/>
						</xsl:for-each>
						<xsl:for-each select="$methodraises">
							<xsl:text> | </xsl:text>
							<xsl:value-of select="ancestor::method/@name"/>
						</xsl:for-each>
						<xsl:text> ) </xsl:text>
					</xsl:when>

					<xsl:otherwise>
						<xsl:text> ( </xsl:text>
						<xsl:for-each select="$getraises[1]">
							<xsl:value-of select="ancestor::attribute/@name"/>
						</xsl:for-each>
						<xsl:for-each select="$getraises[position() &gt; 1]">
							<xsl:text> | </xsl:text>
							<xsl:value-of select="ancestor::attribute/@name"/>
						</xsl:for-each>
						<xsl:for-each select="$setraises">
							<xsl:text> | </xsl:text>
							<xsl:value-of select="ancestor::attribute/@name"/>
						</xsl:for-each>
						<xsl:for-each select="$methodraises">
							<xsl:text> | </xsl:text>
							<xsl:value-of select="ancestor::method/@name"/>
						</xsl:for-each>
						<xsl:text> ) </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> &gt;
</xsl:text>
			</xsl:for-each>
		</xsl:for-each>

	</xsl:template>

	<xsl:template name="produce-feature-if-raises-code">
		<!--   this is the exception block in a raises, setraises or getraises element  -->
		<xsl:param name="exception"/>
		<xsl:param name="constant"/>
		<xsl:if test="contains(string($exception),concat($constant/@name,':'))">
			<!--  change context to parent (which could be raises, setraises or getraises  -->
			<xsl:for-each select="parent::*">												  
				<xsl:text>|</xsl:text>
				<xsl:value-of select="parent::*/@name"/>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
			
	<!--  generate element that depend on the source document   -->				
    <xsl:template name="dynamic-elements">

		<xsl:text>&lt;!ENTITY % statement "%framework-statement;|%assertion;</xsl:text>

		<xsl:for-each select="$attributes">
			<xsl:sort select="@name"/>
			<xsl:variable name="current" select="."/>
			<xsl:if test="not(preceding::attribute[@name=$current/@name])">
				<xsl:text> | </xsl:text>
				<xsl:value-of select="@name"/>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$methods[@name != 'handleEvent']">
			<xsl:sort select="@name"/>
			<xsl:variable name="current" select="."/>
			<xsl:if test="not(preceding::method[@name=$current/@name] or @name = $attributes/@name)">
				<xsl:text> | </xsl:text>
				<xsl:value-of select="@name"/>
			</xsl:if>
		</xsl:for-each>
		<xsl:text> "&gt;
</xsl:text>
	</xsl:template>

	<!--  produce an attribute with the name specified by $paramName,
	      use specified by $use and whose type is appropriate for
		  the type of the param   -->
	<xsl:template name="param-type">
		<xsl:param name="paramName"/>
		<xsl:param name="type"/>
		<xsl:param name="use"/>
		<xsl:text>    </xsl:text>
		<xsl:value-of select="normalize-space($paramName)"/>
		<xsl:choose>
			<xsl:when test="$type='boolean'">
				<xsl:text> (true | false) </xsl:text>
			</xsl:when>

			<xsl:otherwise>
				<xsl:text> CDATA </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="$use"/>
		<xsl:text>
</xsl:text>
	</xsl:template>

</xsl:stylesheet>
