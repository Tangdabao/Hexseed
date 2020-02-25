package com.st.bluenrgmesh.models.meshdata.nodecomparable;

import android.support.annotation.NonNull;

import java.io.Serializable;



public class NodeData implements Serializable, Comparable<NodeData> {

    String address;
    Integer elementCount;
    Integer nodeNumber;

    public int getNodeNumber() {
        return nodeNumber;
    }

    public void setNodeNumber(int nodeNumber) {
        this.nodeNumber = nodeNumber;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public int getElementCount() {
        return elementCount;
    }

    public void setElementCount(int elementCount) {
        this.elementCount = elementCount;
    }


    @Override
    public int compareTo(NodeData node) {
        return node.nodeNumber.compareTo(node.nodeNumber);
    }
}
