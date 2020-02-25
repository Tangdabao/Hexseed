package com.st.bluenrgmesh.models.meshdata;

import java.io.Serializable;


public class Properties implements Serializable {

    private boolean relay;

    public boolean getRelay() {
        return this.relay;
    }

    public void setRelay(boolean relay) {
        this.relay = relay;
    }

    private boolean proxy;

    public boolean getProxy() {
        return this.proxy;
    }

    public void setProxy(boolean proxy) {
        this.proxy = proxy;
    }

    private boolean friend;

    public boolean getFriend() {
        return this.friend;
    }

    public void setFriend(boolean friend) {
        this.friend = friend;
    }

    private boolean lowPower;

    public boolean getLowPower() {
        return this.lowPower;
    }

    public void setLowPower(boolean lowPower) {
        this.lowPower = lowPower;
    }


}
