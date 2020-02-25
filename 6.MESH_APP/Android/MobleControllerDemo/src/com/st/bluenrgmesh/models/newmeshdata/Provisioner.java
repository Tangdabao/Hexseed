package com.st.bluenrgmesh.models.newmeshdata;

import java.io.Serializable;
import java.util.ArrayList;



class Provisioner implements Serializable {

    private String provisionerName;

    public String getProvisionerName() { return this.provisionerName; }

    public void setProvisionerName(String provisionerName) { this.provisionerName = provisionerName; }

    private String UUID;

    public String getUUID() { return this.UUID; }

    public void setUUID(String UUID) { this.UUID = UUID; }

    private ArrayList<AllocatedUnicastRange> allocatedUnicastRange;

    public ArrayList<AllocatedUnicastRange> getAllocatedUnicastRange() { return this.allocatedUnicastRange; }

    public void setAllocatedUnicastRange(ArrayList<AllocatedUnicastRange> allocatedUnicastRange) { this.allocatedUnicastRange = allocatedUnicastRange; }

    private ArrayList<AllocatedGroupRange> allocatedGroupRange;

    public ArrayList<AllocatedGroupRange> getAllocatedGroupRange() { return this.allocatedGroupRange; }

    public void setAllocatedGroupRange(ArrayList<AllocatedGroupRange> allocatedGroupRange) { this.allocatedGroupRange = allocatedGroupRange; }

    private String allocatedSceneRange;

    public String getAllocatedSceneRange() { return this.allocatedSceneRange; }

    public void setAllocatedSceneRange(String allocatedSceneRange) { this.allocatedSceneRange = allocatedSceneRange; }

}
