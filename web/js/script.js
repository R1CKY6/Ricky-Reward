const app = new Vue({
    el: '#app',

    data: {
        nomeRisorsa : GetParentResourceName(),
        screen : '',

        name : '',

        customMessage : '',
        car : '',
        customplate : '',
        item : '',
        itemAmount : '',
        selectedReward : 0,
        moneyTypeSelected : 0,

        animazione : {
            "reward" : true
        },

        checkbox : {
            'car' : false
        },

        locales : {},

        rewardType : [
            {
                label : "Money",
                id : "money"
            },
            {
                label : "Car",
                id : "car"
            },
            {
                label : "Item",
                id : "item"
            },
        ],

        moneyType : [
            {
                label : "Money",
                account : "money"
            },
            {
                label : "Bank",
                account : "bank"
            },
            {
                label : "Black Money",
                account : "black_money"
            }
        ],


        moneyInfo : {
            label : '',
            type : '',
            amount : ''
        },


        createdReward : [],


        userReward : [],

        rewardInfo : false,
        codeCreated : false,

        codeCopied : false,
        errorVehicle : false,
        errorCode : false,

        staff : false,

        code : '',

        dataReward : {}
    },

    methods: {
        postNUI(type, data) {
            return $.post(`https://${this.nomeRisorsa}/${type}`, JSON.stringify(data))
        },


        changeScreen(screen) {
            this.screen = screen 
            if(screen == 'createdreward') {
                this.selectedReward = 0
                this.creatingReward = false
            } else {
                this.creatingReward = true
            }

            if(screen=='createdreward') {
                this.rewardInfo = false
            }

            if(screen=='history') {
                this.rewardInfo = false
            }
        },

        upper(string) {
            if(!string) {
                return
            }
            return string.toUpperCase();
        },

        previousReward() {
            if(this.selectedReward > 0) {
                this.selectedReward--;
                this.animazione.reward = false;
                setTimeout(() => {
                    this.animazione.reward = true;                
                }, 500);
            }
        },
    
        nextReward() {
            if(this.selectedReward < this.rewardType.length - 1) {
                this.selectedReward++;
                this.animazione.reward = false;
                setTimeout(() => {
                    this.animazione.reward = true;                
                }, 200);
            }
        },


        previousMoneyType() {
            if(this.moneyTypeSelected > 0) {
                this.moneyTypeSelected--;
                this.animazione.reward = false;
                setTimeout(() => {
                    this.animazione.reward = true;                
                }, 500);
            }
        },

        nextMoneyType() {
            if(this.moneyTypeSelected < this.moneyType.length - 1) {
                this.moneyTypeSelected++;
                this.animazione.reward = false;
                setTimeout(() => {
                    this.animazione.reward = true;                
                }, 200);
            }
        },
    
    
        nextStep() {
            this.car = ''
            this.customplate = ''
            this.checkbox.car = false
            this.customMessage = ''
            this.moneyInfo = {
                label : '',
                type : '',
                amount : ''
            }
            if(this.selectedReward == 0) { // Money
                this.changeScreen('moneytwo')
            } else if(this.selectedReward == 1) { // Car
                this.changeScreen('cartwo')
            } else if(this.selectedReward == 2) { // Item
                this.changeScreen('itemtwo')
            }
        },

        async lastStep(check, checkCar) {
            if(!check) {
                return
            }
            if(checkCar) {
                var exist = await this.postNUI('checkVehicle', {
                    car : this.car
                })
                if(!exist) {
                    this.errorVehicle = true
                    setTimeout(() => {
                        this.errorVehicle = false
                    }, 5000);
                    return
                }
            }
            this.customMessage = ''
            if(this.selectedReward == 0) {
                this.moneyInfo.type = this.moneyType[this.moneyTypeSelected].account
                this.moneyInfo.label = this.moneyType[this.moneyTypeSelected].label
                this.changeScreen('moneyone')
            }
            this.changeScreen('customMessage')
        },

        async createReward() {
            var data = {}
            if(this.selectedReward == 0) {

                data = {
                    type : "money",
                    account : this.moneyInfo.type,
                    amount : this.moneyInfo.amount,
                    message : this.customMessage || this.locales.none
                }
            } else if(this.selectedReward == 1) {
                data = {
                    type : "car",
                    car : this.car,
                    plate : this.customplate,
                    message : this.customMessage || this.locales.none
                }
            } else if(this.selectedReward == 2) {
                data = {
                    type : "item",
                    item : this.item,
                    amount : this.itemAmount,
                    message : this.customMessage || this.locales.none
                }
            }


            var code = await this.postNUI('createReward', data)
            this.codeCreated = code
            
            this.changeScreen('rewardinfo')
        },


        changeValueCheckbox(type, value) {
            this.checkbox[type] = value
            if(type == 'car') {
                this.customplate = ''
            }
        },


        getColorSelect(value) {
            if(value == 'createreward') {
                if(this.screen == value || this.creatingReward) {
                    return {
                        backgroundColor : "rgba(232, 223, 20, 0.33)",
                    }
                }
            } else {
                if(this.screen == value) {
                    return {
                        backgroundColor : "rgba(232, 223, 20, 0.33)",
                    }
                }
            }
        },

        copyCode() {
            this.copy(this.codeCreated)
            this.codeCopied = true 
            setTimeout(() => {
                this.codeCopied = false
            }, 5000);
        },


        blurCode(v) {
            if(v.viewCode) {
                return {
                    filter : "blur(0px)",
                }
            } else {
                return {
                    filter : "blur(3px)",
                }
            }
        },



        viewCode(v,k, user) {
            if(v.viewCode) {
                if(user) {
                    this.userReward[k].viewCode = false
                } else {
                    this.createdReward[k].viewCode = false
                }
            } else {
                if(user) {
                    this.userReward[k].viewCode = true
                } else {
                    this.createdReward[k].viewCode = true
                }
            }
            
        },

        hideCode(v,k, user) {
            if(!user) {
                this.createdReward[k].viewCode = false
            } else {
                this.userReward[k].viewCode = false
            }
        },


        viewRewardInfo(v) {
            this.rewardInfo = v
        },

        copy(string, code) {
            if(code) {
                this.codeCopied = true
                setTimeout(() => {
                    this.codeCopied = false
                }, 5000);
            }
            var $temp = $("<input>");
            $("body").append($temp);
            $temp.val(string).select();
            document.execCommand("copy");
            $temp.remove();
        },

        async deleteReward() {
            var reward = this.rewardInfo 
            var deleted = this.postNUI('deleteReward', reward.code)
            if(!deleted) {
                console.log("Error while deleting")
            } else {
                this.rewardInfo = false

            }
        },


        getIfNext(type) {
            if(type == 'car') {
                if(this.car != '') {
                    return {
                        filter : "grayscale(0%)",
                        cursor : "pointer"
                    }
                } else {
                    return {
                        filter : "grayscale(100%)",
                        cursor : "default"
                    }
                }
            } else if(type == 'money') {
                if(this.moneyInfo.amount != '') {
                    return {
                        filter : "grayscale(0%)",
                        cursor : "pointer"
                    }
                } else {
                    return {
                        filter : "grayscale(100%)",
                        cursor : "default"
                    }
                }
            } else if(type == 'item') {
                if(this.item != '' && this.itemAmount != '') {
                    return {
                        filter : "grayscale(0%)",
                        cursor : "pointer"
                    }
                } else {
                    return {
                        filter : "grayscale(100%)",
                        cursor : "default"
                    }
                }
            }
        },


        getIfNext2(type) {
            if(type == 'car') {
                if(this.car != '') {
                    return true
                } else {
                    return false
                }
            } else if(type == 'money') {
                if(this.moneyInfo.amount != '') {
                    return true
                } else {
                    return false
                }
            } else if(type == 'item') {
                if(this.item != '' && this.itemAmount != '') {
                    return true
                } else {
                    return false
                }
            }
        },


        async redeemCode() {
            var code = this.code 
            var existCode = await this.postNUI('checkCode', code)
            if(!existCode) {
                this.errorCode = true
                setTimeout(() => {
                    this.errorCode = false
                }, 5000);
            } else {
                this.code = ''
                var data = await this.postNUI('redeemCode', code)
                if(data) {
                    this.dataReward = data
                    this.changeScreen('rewardinfouser')
                }
            }
        },


        copyIdentifier() {
            var identifier = this.rewardInfo.userInfo.identifier
            this.copy(identifier)
        },

    }
});


window.addEventListener('message', function(event) {
    var data = event.data;
    if (data.type === "OPEN") {
        $("#app").fadeIn(500)
    } else if(data.type === "SET_LOCALES") {
        app.locales = data.locales
        for(const[k,v] of Object.entries(app.moneyType)) {
            if(v.account == 'money') {
                v.label = app.locales.money
            } else if(v.account == 'bank') {
                v.label = app.locales.bank
            } else if(v.account == 'black_money') {
                v.label = app.locales.black_money
            }
        }
    } else if(data.type === "UPDATE_STAFF_REWARDS") {
        app.createdReward = data.staffRewards
        for(const[k,v] of Object.entries(app.createdReward)) {
            v.data = JSON.parse(v.data)
            v.userInfo = JSON.parse(v.userInfo)
        }
    } else if(data.type === "SET_STAFF") {
        app.staff = data.staff
        if(data.staff) {
            app.screen = 'createreward'
        } else {
            app.screen = 'redeem_code'
        }
    } else if(data.type === "UPDATE_USER_REWARDS") {
        app.userReward = data.userRewards
        for(const[k,v] of Object.entries(app.userReward)) {
            v.data = JSON.parse(v.data)
            v.userInfo = JSON.parse(v.userInfo)
        }
    } else if(data.type === "SET_NAME") {
        app.name = data.name
    }
})

document.onkeyup = function (data) {
    if (data.key == 'Escape' && app.screen == 'cartwo') {
        app.changeScreen('createreward')
    } else if(data.key == 'Escape' && app.screen == 'moneytwo') {
        app.changeScreen('createreward')
    } else if(data.key == 'Escape' && app.screen == 'customMessage') {
        if(app.selectedReward == 0) {
            app.changeScreen('moneytwo')
        } else if(app.selectedReward == 1) {
            app.changeScreen('cartwo')
        }
    } else if(data.key == 'Escape' && app.screen == 'rewardinfo') {
        app.changeScreen('createreward')
    } else if(data.key == 'Escape' && app.screen == 'createdreward') {
        app.changeScreen('createreward')
    } else if(data.key == 'Escape' && app.screen == 'createreward') {
        $("#app").fadeOut(500)
        app.postNUI('close')
        setTimeout(() => {
            app.screen = ''            
        }, 1000);
    } else if(data.key == 'Escape' && app.screen == 'redeem_code') {
        $("#app").fadeOut(500)
        app.postNUI('close')
        setTimeout(() => {
            app.screen = ''            
        }, 1000);
    } else if(data.key == 'Escape' && app.screen == 'history') {
        $("#app").fadeOut(500)
        app.postNUI('close')
        setTimeout(() => {
            app.screen = ''            
        }, 1000);
    }
};
