// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract FreelanceContract {
    // Define employer
    address public employerAddress;

    event JobPaymentReceived(address addr, uint amount, uint contractBalance);


    constructor() {
        employerAddress = msg.sender;
    }

    struct Freelancer {
        address payable freelancerAddress;
        string freelancerName;
        uint projectDays;
        uint paymentAmount;
        bool canWithdraw;
    }

    Freelancer[] public freelancer;

    modifier onlyEmployer() {
        require(msg.sender == employerAddress, "Only an employer can add a freelancer.");
        _;
    }

    // Add freelancer to contract
    function addFreelancer(
        address payable freelancerAddress,
        string memory freelancerName,
        uint projectDays,
        uint paymentAmount,
        bool canWithdraw
    ) public {
        freelancer.push(Freelancer(
            freelancerAddress,
            freelancerName,
            projectDays,
            paymentAmount,
            canWithdraw
        ));
    }

    function balanceOf() public view returns(uint) {
        return address(this).balance;
    }

     // Deposit funds to contract, specifically to a kid's account
    function depositPayment(address freelancerAddress) payable public {
        addToFreelancerBalance(freelancerAddress);
    }


    function addToFreelancerBalance(address freelancerAddress) private {
        for(uint i = 0; i < freelancer.length; i++) {
            if(freelancer[i].freelancerAddress == freelancerAddress) {
                freelancer[i].paymentAmount += msg.value;
                emit JobPaymentReceived(freelancerAddress, msg.value, balanceOf());
            }
        }
    }

    function getFreelancer(address freelancerAddress) view private returns(uint) {
        for (uint i = 0; i < freelancer.length; i++) {
            if (freelancer[i].freelancerAddress == freelancerAddress) {
                return i;
            }
        }
        return 2;
    }


    // Freelancer checks if they are able to withdraw
    function availableToWithdraw(address freelancerAddress) public returns(bool) {
        uint i = getFreelancer(freelancerAddress);
        require(block.timestamp > freelancer[i].projectDays, "You cannot withdraw your payment yet");
        if (block.timestamp > freelancer[i].projectDays) {
            freelancer[i].canWithdraw = true;
            return true;
        } else {
            return false;
        }
    }

    // Freelancer can withdraw payment
    function withdrawPayment(address payable freelancerAddress) payable public {
        uint i = getFreelancer(freelancerAddress);
        require(msg.sender == freelancer[i].freelancerAddress, "You must be the freelancer to withdraw");
        require(freelancer[i].canWithdraw == true, "You are not able to withdraw at this time");
        freelancer[i].freelancerAddress.transfer(freelancer[i].paymentAmount);
    }
}




/*
Time in solidity:
5 seconds = 5
5 minutes = 5*60
5 hours = 5*60*60
5 days = 5*24*60*60
5 weeks = 5*7*24*60*60
5 months = 5*30*7*24*60*60
5 years = 5*365*24*60*60
*/