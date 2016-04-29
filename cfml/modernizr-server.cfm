<cfscript>
	/*
	*	---Server Side Modernizr for cfml applications---
	*	Big props to James G Pearce, http://tripleodeon.com, for the
	*	original PHP server-side inspiration and to (of course)
	*	Faruk Ates and Paul Irish for the Modernizr JS code:
	*			http://www.modernizr.com/
	*
	*	Code by Matthew Reinbold, http://voxpopdesign.com
	*/

	//realtive path to the modernizr file
	modernizr_js = '../modernizr.js/modernizr.js';

	//the key in session and cookie scopes to hold Modernizr values
	key = "Modernizr";

	//return variable for Modernizr properties available to including page
	stcModernizr = StructNew();
</cfscript>

<cfif StructKeyExists(session,key)>
	<!--- if session scope exists for browser, just use that --->
	<cfset stcModernizr = session[key] />
<cfelseif StructKeyExists(cookie,key)>
	<!--- if session scope doesn't exist but cookie does, use that --->
	<cfset stcModernizr = parseCookie(cookie[key]) />
	<cfset session[key] = stcModernizr />
<cfelse>
	<!--- session and cookie scopes don't exist. use js to write values to cookie --->
	<html>
		<head>
			<script type="text/javascript">
				<cffile action="read" file="#ExpandPath(modernizr_js)#" variable="jsContents" />
				<cfoutput>
					#jsContents#
					#writeJsToCookie()#
				</cfoutput>
			</script>
		</head>
		<body>
		</body>
	</html>
</cfif>

<cffunction name="parseCookie" hint="reads the cookie values held in the key and populates a structure">
	<cfargument name="lCookieVals" type="string">

	<cfset var stcVals = StructNew() />
	<cfset var stcTemp = StructNew() />
	<cfset var lValue = "" />
	<cfset var label = "" />
	<cfset var i = "" />
	<cfset var j = "" />

	<cfloop index="i" list="#arguments.lCookieVals#" delimiters="|">
		<cfset label = ListGetAt(i,1,":") />
		<cfset lValue = Right(i,Len(i) - ReFind(":",i)) />

		<cfif ListLen(lValue,"/") eq 1>
			<cfset stcVals[ListGetAt(i,1,":")] = lValue />
		<cfelse>
			<cfset stcTemp = StructNew() />
			<cfloop index="j" list="#lValue#" delimiters="/">
				<cfset stcTemp[ListGetAt(j,1,":")] = ListGetAt(j,2,":") />
			</cfloop>
			<cfset stcVals[ListGetAt(i,1,":")] = stcTemp />
		</cfif>
	</cfloop>

	<cfreturn stcVals />
</cffunction>

<cffunction name="writeJsToCookie" hint="JavaScript to write Modernizr values to a cookie and reload the current page">
	<cfset var strJs = "" />

	<cfsavecontent variable="strJs">
      var m=Modernizr,c='';
      for(var f in m){
        if(f[0]=='_'){continue;}
        var t=typeof m[f];
        if(t=='function'){continue;}
        c+=(c?'|':'<cfoutput>#key#</cfoutput>=')+f+':';
        if(t=='object'){
          for(var s in m[f]){
            c+='/'+s+':'+(m[f][s]?'1':'0');
          }
        }else{
          c+=m[f]?'1':'0';
        }
      }
      c+=';path=/';
      try{
        document.cookie=c;
        document.location.reload();
      }catch(e){}
	</cfsavecontent>

	<cfreturn strJs />
</cffunction>