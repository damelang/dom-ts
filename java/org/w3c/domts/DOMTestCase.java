/*
 * Copyright (c) 2001 World Wide Web Consortium,
 * (Massachusetts Institute of Technology, Institut National de
 * Recherche en Informatique et en Automatique, Keio University). All
 * Rights Reserved. This program is distributed under the W3C's Software
 * Intellectual Property License. This program is distributed in the
 * hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.
 * See W3C License http://www.w3.org/Consortium/Legal/ for more details.
 */

package org.w3c.domts;

import javax.xml.parsers.*;
import org.w3c.dom.*;
import org.w3c.domts.*;

/**
 *    This is an abstract base class for generated DOM tests
 */
public abstract class DOMTestCase {
	abstract public void runTest(DOMTestFramework _framework) throws java.lang.Throwable;
	abstract public boolean isCompatible(DocumentBuilderFactory factory, DOMImplementation domImpl);
	abstract public void setAttributes(DocumentBuilderFactory factory);
	abstract public String getTargetURI();
}

