package com.st.bluenrgmesh.models.newmeshdata;

import java.io.Serializable;



public class Group implements Serializable {

    private String name;

    public String getName() { return this.name; }

    public void setName(String name) { this.name = name; }

    private String address;

    public String getAddress() { return this.address; }

    public void setAddress(String address) { this.address = address; }

    private String parentAddress;

    public String getParentAddress() { return this.parentAddress; }

    public void setParentAddress(String parentAddress) { this.parentAddress = parentAddress; }
}
