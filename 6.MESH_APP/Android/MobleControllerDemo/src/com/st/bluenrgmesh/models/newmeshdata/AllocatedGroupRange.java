package com.st.bluenrgmesh.models.newmeshdata;

import java.io.Serializable;



public class AllocatedGroupRange implements Serializable {

    private String lowAddress;

    public String getLowAddress() { return this.lowAddress; }

    public void setLowAddress(String lowAddress) { this.lowAddress = lowAddress; }

    private String highAddress;

    public String getHighAddress() { return this.highAddress; }

    public void setHighAddress(String highAddress) { this.highAddress = highAddress; }
}
