<cfinclude template="modernizr-server.cfm" />

<cfoutput>
	The server knows:
	<cfloop index="feature" list="#StructKeyList(stcModernizr)#">
		<cfif IsStruct(stcModernizr[feature]) eq true>
			<br /> #uCase(feature)# -
			<cfloop index="nestedFeature" list="#StructKeyList(stcModernizr[feature])#">
				<br />&nbsp;&nbsp;&nbsp; #nestedfeature#: #stcModernizr[feature][nestedfeature]#
			</cfloop>
		<cfelse>
			<br /> #feature#: #stcModernizr[feature]#
		</cfif>
	</cfloop>
</cfoutput>