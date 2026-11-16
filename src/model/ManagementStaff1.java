package model;

import java.io.Serializable;
import java.util.*;
import java.util.Date;
import java.math.BigDecimal;

public class ManagementStaff1 extends Member1 implements Serializable {
    private String managementStaffCode;
    private String position;

    public ManagementStaff1() {}
    public String getManagementStaffCode() { return managementStaffCode; }
    public void setManagementStaffCode(String managementStaffCode) { this.managementStaffCode = managementStaffCode; }
    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }

}
