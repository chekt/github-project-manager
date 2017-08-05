<template>
  <div class="hello">
    <transition name="fade" mode="out-in" appear>
      <template v-if="!isLoggedIn">
        <div class="login-container" key="'loggingIn'">
          <input 
          v-model="username" 
          v-on:keyup.enter="login(username, password)"
          type="text"
          class="login-input"
          placeholder="github username" />
          <input 
          v-model="password" 
          v-on:keyup.enter="login(username, password)"
          type="password" 
          class="login-input"
          placeholder="github password" />
          <div
          v-on:click="login(username, password)" 
          class="login-btn">
            {{isLoggedIn ? 'Logged In' : 'Login'}}
          </div>
        </div>
      </template>
      <template v-else>
        <div class="after-login-container" key="'loggedIn'">
          <div class="organizations-wrapper">
            <template v-if="getKeys(myOrgLogins).length < 1">
              <div class="no-organization-text">You don't have any organization</div>
            </template>
            <template v-if="getKeys(myOrgLogins).length > 0">
              <div class="instruction-text">Choose a organization to get milestones</div>
              <div class="organizations">
                <div 
                v-for="orgLogin in myOrgLogins"
                v-bind:key="orgLogin"
                v-on:click="onClickGetMilestones(orgLogin)"
                class="organization-btn">
                  {{orgLogin}}
                </div>
              </div>
            </template>
          </div>
          <div class="repositories-wrapper">
            <transition name="fade" mode="out-in" appear>
              <div v-if="getKeys(orgRepositories).length < 1" key="'noRepository'">
                <div class="no-repository-text">No repository</div>
              </div>
              <div v-else key="'hasRepository'">
                <transition name="fade" mode="out-in" appear>
                  <div v-if="isViewStarredActive" key="'starredTabView'">
                    <transition-group name="fade" mode="out-in" tag="div" appear>
                      <div 
                      v-for="(value, repoName) in orgRepositories"
                      v-bind:key="repoName"
                      v-if="+orgRepositories[repoName].milestoneTotalCount > 0 && orgRepositories[repoName].starTaggedMilestoneTotalCount > 0"
                      class="repo">
                        <div class="repo-name">{{repoName}}</div>
                        <transition name="fade" mode="out-in" appear>
                          <div class="milestone-wrapper" v-if="+orgRepositories[repoName].milestoneTotalCount < 1" key="'hasNoMilestone'">
                            <div class="no-milestone-text">No milestone</div>
                          </div>
                          <div class="milestone-wrapper" v-else key="'hasMilestone'">
                            <transition-group name="fade" mode="out-in" tag="div" appear>
                              <div 
                              v-for="(milestoneObj, milestoneId) in orgRepositories[repoName].milestones"
                              v-bind:key="milestoneId"
                              v-if="hasStarTagForMilestone(milestoneId)"
                              v-on:click="setStarTagForMilestone(repoName, milestoneId)"
                              class="milestone">
                                <div class="info-container">
                                  <div class="milestone-title">{{milestoneObj.title ? milestoneObj.title : 'no title'}}</div>
                                  <div 
                                  v-bind:class="{'no-info': !milestoneObj.dueOn}" 
                                  class="milestone-due">
                                    {{milestoneObj.dueOn ? 'Due by ' + milestoneObj.dueOn : 'no due date'}}
                                  </div>
                                  <div 
                                  v-bind:class="{'no-info': !milestoneObj.description}" 
                                  class="milestone-description">
                                    {{milestoneObj.description ? milestoneObj.description : 'no description'}}
                                  </div>
                                </div>
                                <div class="info-container">
                                  <div class="info-inner-stack">
                                    <div class="milestone-state">{{milestoneObj.state ? milestoneObj.state : 'no state'}}</div>
                                  </div>
                                  <div class="info-inner-stack">
                                    <div class="milestone-bargraph">
                                      <div class="background">
                                        <div 
                                        v-bind:style="{transform: 'scaleX(' + milestoneObj.closedIssues / milestoneObj.totalIssues + ')'}"
                                        class="foreground"></div>
                                      </div>
                                    </div>
                                  </div>
                                  <div class="info-inner-stack">
                                    <div class="milestone-issues">{{milestoneObj.totalIssues ? Math.round(milestoneObj.closedIssues / milestoneObj.totalIssues * 100) : 0}}% complete</div>
                                    <div class="milestone-issues">{{milestoneObj.openIssues ? milestoneObj.openIssues : 0}} open</div>
                                    <div class="milestone-issues">{{milestoneObj.closedIssues ? milestoneObj.closedIssues : 0}} closed</div>
                                  </div>
                                </div>                  
                              </div>
                            </transition-group>
                          </div>
                        </transition>
                      </div>
                    </transition-group>
                  </div>
                  <div v-else key="'unstarredTabView'">
                    <transition-group name="fade" mode="out-in" tag="div" appear>
                      <div 
                      v-for="(value, repoName) in orgRepositories"
                      v-bind:key="repoName"
                      v-if="+orgRepositories[repoName].milestoneTotalCount > 0 && orgRepositories[repoName].starTaggedMilestoneTotalCount < +orgRepositories[repoName].milestoneTotalCount"
                      class="repo">
                        <div class="repo-name">{{repoName}}</div>
                        <transition name="fade" mode="out-in" appear>
                          <div class="milestone-wrapper" v-if="+orgRepositories[repoName].milestoneTotalCount < 1" key="'hasNoMilestone'">
                            <div class="no-milestone-text">No milestone</div>
                          </div>
                          <div class="milestone-wrapper" v-else key="'hasMilestone'">
                              <transition-group name="fade" mode="out-in" tag="div" appear>
                                <div 
                                v-for="(milestoneObj, milestoneId) in orgRepositories[repoName].milestones"
                                v-bind:key="milestoneId"
                                v-if="!hasStarTagForMilestone(milestoneId)"
                                v-on:click="setStarTagForMilestone(repoName, milestoneId)"
                                class="milestone">
                                  <div class="info-container">
                                    <div class="milestone-title">{{milestoneObj.title ? milestoneObj.title : 'no title'}}</div>
                                    <div 
                                    v-bind:class="{'no-info': !milestoneObj.dueOn}" 
                                    class="milestone-due">
                                      {{milestoneObj.dueOn ? 'Due by ' + milestoneObj.dueOn : 'no due date'}}
                                    </div>
                                    <div 
                                    v-bind:class="{'no-info': !milestoneObj.description}" 
                                    class="milestone-description">
                                      {{milestoneObj.description ? milestoneObj.description : 'no description'}}
                                    </div>
                                  </div>
                                  <div class="info-container">
                                    <div class="info-inner-stack">
                                      <div class="milestone-state">{{milestoneObj.state ? milestoneObj.state : 'no state'}}</div>
                                    </div>
                                    <div class="info-inner-stack">
                                      <div class="milestone-bargraph">
                                        <div class="background">
                                          <div 
                                          v-bind:style="{transform: 'scaleX(' + milestoneObj.closedIssues / milestoneObj.totalIssues + ')'}"
                                          class="foreground"></div>
                                        </div>
                                      </div>
                                    </div>
                                    <div class="info-inner-stack">
                                      <div class="milestone-issues">{{milestoneObj.totalIssues ? Math.round(milestoneObj.closedIssues / milestoneObj.totalIssues * 100) : 0}}% complete</div>
                                      <div class="milestone-issues">{{milestoneObj.openIssues ? milestoneObj.openIssues : 0}} open</div>
                                      <div class="milestone-issues">{{milestoneObj.closedIssues ? milestoneObj.closedIssues : 0}} closed</div>
                                    </div>
                                  </div> 
                                </div>
                              </transition-group>
                          </div>
                        </transition>
                      </div>
                    </transition-group>
                  </div>
                </transition>
              </div>
            </transition>
          </div>
          <template v-if="getKeys(orgRepositories).length > 0">
            <div 
            v-on:click="toggleViewStarred()"
            v-bind:class="{'active': isViewStarredActive}"
            class="svg-btn-fab">
              <svg fill="#FFFFFF" height="48" viewBox="0 0 24 24" width="48" xmlns="http://www.w3.org/2000/svg">
                <path d="M0 0h24v24H0z" fill="none"/>
                <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/>
                <path d="M0 0h24v24H0z" fill="none"/>
              </svg>
            </div>
          </template>
        </div>
      </template>   
    </transition>
  </div>
</template>

<script>
export default {
  name: 'hello',
  data () {
    return {
      urlRestPrefix: 'https://api.github.com',
      urlGraphql: 'https://api.github.com/graphql',
      options: {
        headers: {
          Authorization: null
        }
      },
      username: null,
      password: null,
      maintainPassword$i: null,
      syncingMilestoneData$i: null,
      isLoggedIn: false,
      myOrgLogins: [],
      selectedOrgLogin: null,
      orgRepositories: {},
      repoMilestones: {},
      milestoneStarTag: {},
      isViewStarredActive: true
    }
  },
  created: function () {
    // getCredentials from cookie
    let ghCredentials = this.getCredentialsFromCookie()
    // if there is valid login credential no need to login again
    if (ghCredentials.username && ghCredentials.password) {
      this.username = ghCredentials.username
      this.password = ghCredentials.password
      setTimeout(() => { this.login(this.username, this.password) }, 1000)
    } else if (ghCredentials.username) {
      this.username = ghCredentials.username
    } else {
      this.isLoggedIn = false
    }
  },
  methods: {
    getKeys: function (obj) {
      return Object.keys(obj)
    },
    popupAlert: function (message) {
      alert(message)
    },
    setCookie: function (cname, cvalue, date, domain) {
      document.cookie = encodeURIComponent(cname) + '=' + encodeURIComponent(cvalue) + ';expires=' + date + ';domain=' + domain + ';path=/'
    },
    getCookie: function (cname) {
      let name = encodeURIComponent(cname) + '='
      let cookie = document.cookie
      let ca = cookie.split(';')
      for (let i = 0; i < ca.length; i++) {
        let c = ca[i]
        while (c.charAt(0) === ' ') {
          c = c.substring(1)
        }
        if (c.indexOf(name) === 0) {
          return decodeURIComponent(c.substring(name.length, c.length))
        }
      }
      return ''
    },
    deleteCookie: function (cname) {
      this.setCookie(cname, 'meaning_less_string', 'Thu, 01 Jan 1970 00:00:00 UTC', window.location.hostname)
    },
    startMaintainingCredentials: function (username, password) {
      // Parameters
      let updateCredentialsInterval = 5 // seconds
      // Begin maintaining credentials
      this.storeCredentialsInCookie(username, password)
      this.stopMaintainingCredentials()
      this.maintainPassword$i = setInterval(() => {
        this.storeCredentialsInCookie(username, password)
      }, updateCredentialsInterval * 1000)
    },
    stopMaintainingCredentials: function () {
      if (this.maintainPassword$i) clearInterval(this.maintainPassword$i)
    },
    startSyncingMilestoneData: function () {
      // Parameters
      let syncInterval = 60 * 10 // seconds
      // Start syncing
      this.syncAllMilestoneData()
      this.stopSyncingMilestoneData()
      this.syncingMilestoneData$i = setInterval(() => {
        this.syncOnlyStarTaggedMilestoneData()
      }, syncInterval * 1000)
    },
    stopSyncingMilestoneData: function () {
      if (this.syncingMilestoneData$i) clearInterval(this.syncingMilestoneData$i)
    },
    syncAllMilestoneData: function () {
      for (let repoName in this.orgRepositories) {
        this.getRepoMilestones(this.selectedOrgLogin, repoName).then(
          response => {
            this.onMilestoneDetailData(repoName, response)
          },
          error => {
            if (error.message) this.popupAlert(error.message)
          }
        )
      }
    },
    syncOnlyStarTaggedMilestoneData: function () {
      for (let repoName in this.orgRepositories) {
        if (this.orgRepositories[repoName].starTaggedMilestoneTotalCount > 0) {
          this.getRepoMilestones(this.selectedOrgLogin, repoName).then(
            response => {
              this.onMilestoneDetailData(repoName, response)
            },
            error => {
              if (error.message) this.popupAlert(error.message)
            }
          )
        }
      }
    },
    onMilestoneDetailData: function (repoName, arrayData) {
      for (let i = 0; i < arrayData.length; i++) {
        let closedIssues = arrayData[i].closed_issues
        let openIssues = arrayData[i].open_issues
        let totalIssues = closedIssues + openIssues
        let dueOn = arrayData[i].due_on
        let description = arrayData[i].description
        let title = arrayData[i].title
        let htmlUrl = arrayData[i].html_url
        let state = arrayData[i].state
        let milestoneId = arrayData[i].id
        this.orgRepositories[repoName].milestones[milestoneId].closedIssues = closedIssues
        this.orgRepositories[repoName].milestones[milestoneId].openIssues = openIssues
        this.orgRepositories[repoName].milestones[milestoneId].totalIssues = totalIssues
        this.orgRepositories[repoName].milestones[milestoneId].dueOn = (new Date(dueOn)).toDateString()
        this.orgRepositories[repoName].milestones[milestoneId].description = description
        this.orgRepositories[repoName].milestones[milestoneId].title = title
        this.orgRepositories[repoName].milestones[milestoneId].htmlUrl = htmlUrl
        this.orgRepositories[repoName].milestones[milestoneId].state = state
        this.orgRepositories[repoName].milestones[milestoneId].htmlUrl = htmlUrl
      }
    },
    getCredentialsFromCookie: function () {
      return {
        username: this.getCookie('ghUsername') ? atob(this.getCookie('ghUsername')) : null,
        password: this.getCookie('ghPassword') ? atob(this.getCookie('ghPassword')) : null
      }
    },
    storeCredentialsInCookie: function (username, password) {
      // Store password in cookiem,, dangerous,, but it only lasts for 10 seconds..
      // Parameters
      let ghUsernameDeletedAfter = 60 * 60 * 24 * 30 // seconds, 30 days
      let ghPasswordDeletedAfter = 10 // seconds
      // Calculate expiration date
      let ghUsernameExpirationDate = new Date()
      ghUsernameExpirationDate.setSeconds(ghUsernameExpirationDate.getSeconds() + ghUsernameDeletedAfter)
      let ghPasswordExpirationDate = new Date()
      ghPasswordExpirationDate.setSeconds(ghPasswordExpirationDate.getSeconds() + ghPasswordDeletedAfter)
      // Set cookie
      this.setCookie('ghUsername', btoa(username), ghUsernameExpirationDate.toUTCString(), window.location.hostname)
      this.setCookie('ghPassword', btoa(password), ghPasswordExpirationDate.toUTCString(), window.location.hostname)
    },
    updateStarTaggedMilestoneTotalCount: function (repoName) {
      let starTaggedMilestoneTotalCount = 0
      if (this.orgRepositories[repoName].milestoneTotalCount > 0) {
        let milestoneIds = Object.keys(this.orgRepositories[repoName].milestones)
        for (let i = 0; i < milestoneIds.length; i++) {
          if (this.milestoneStarTag['ghMilestone::' + milestoneIds[i]]) starTaggedMilestoneTotalCount++
        }
      }
      this.$set(this.orgRepositories[repoName], 'starTaggedMilestoneTotalCount', starTaggedMilestoneTotalCount)
    },
    hasStarTagForMilestone: function (milestoneId) {
      return this.milestoneStarTag['ghMilestone::' + milestoneId] ? 1 : 0
    },
    initializeAllMilestoneTagsFromLocalStorage: function () {
      for (let key in localStorage) {
        if (key.indexOf('ghMilestone::') > -1) {
          this.$set(this.milestoneStarTag, key, +localStorage.getItem(key))
        }
      }
    },
    setStarTagForMilestone: function (repoName, milestoneId) {
      let isStarred = +this.milestoneStarTag['ghMilestone::' + milestoneId]
      if (isStarred) {
        this.$set(this.milestoneStarTag, 'ghMilestone::' + milestoneId, 0)
        localStorage.setItem('ghMilestone::' + milestoneId, 0)
      } else {
        this.$set(this.milestoneStarTag, 'ghMilestone::' + milestoneId, 1)
        localStorage.setItem('ghMilestone::' + milestoneId, 1)
      }
      this.updateStarTaggedMilestoneTotalCount(repoName)
    },
    removeAllMilestoneTagsInLocalStorage: function () {
      for (let key in localStorage) {
        if (key.indexOf('ghMilestone::') > -1) localStorage.removeItem(key)
      }
    },
    toggleViewStarred: function () {
      this.isViewStarredActive = !this.isViewStarredActive
    },
    login: function (username, password) {
      if (this.isLoggedIn) {
        this.popupAlert('You are already logged in!')
      } else if (username && password) {
        this.updateApiAuthorizationHeader(username, password)
        this.getUser().then(
          response => {
            this.onLoginSuccess()
          },
          error => {
            if (error.message) {
              this.popupAlert(error.message)
            }
          }
        )
      } else {
        this.popupAlert('username or password is not entered!')
      }
    },
    logout: function () {
      this.stopMaintainingCredentials()
      this.deleteCookie('ghUsername')
      this.deleteCookie('ghPassword')
      this.updateApiAuthorizationHeader(null, null)
    },
    onLoginSuccess: function () {
      this.isLoggedIn = true
      this.startMaintainingCredentials(this.username, this.password)
      this.initializeAllMilestoneTagsFromLocalStorage()
      this.getMyOrganizations(this.username).then(
        response => {
          this.onMyOrganizationsData(response)
        },
        error => {
          if (error.message) {
            this.popupAlert(error.message)
          }
        }
      )
    },
    onMyOrganizationsData: function (arrayData) {
      // Erase all data first
      this.myOrgLogins = []
      // And update all data again
      for (let i = 0; i < arrayData.length; i++) {
        this.myOrgLogins.push(arrayData[i].login)
      }
    },
    onClickGetMilestones: function (orgLogin) {
      this.selectedOrgLogin = orgLogin
      this.getAllMilestones(orgLogin).then(
        response => {
          this.onOrgMilestoneData(response)
        },
        error => {
          if (error.message) {
            this.popupAlert(error.message)
          }
        }
      )
    },
    onOrgMilestoneData: function (arrayData) {
      for (let i = 0; i < arrayData.length; i++) {
        let repoName = arrayData[i].name
        // Erase all data first
        this.$set(this.orgRepositories, repoName, {})
        this.$set(this.orgRepositories[repoName], 'milestones', {})
        this.$set(this.orgRepositories[repoName], 'milestoneTotalCount', arrayData[i].milestones.totalCount)
        for (let j = 0; j < arrayData[i].milestones.nodes.length; j++) {
          let milestoneId = atob(arrayData[i].milestones.nodes[j].id).split(':Milestone')[1]
          this.$set(this.orgRepositories[repoName].milestones, milestoneId, arrayData[i].milestones.nodes[j])
          if (this.orgRepositories[repoName].milestones[milestoneId].dueOn) {
            let dateString = (new Date(this.orgRepositories[repoName].milestones[milestoneId].dueOn)).toDateString()
            this.orgRepositories[repoName].milestones[milestoneId].dueOn = dateString
          }
        }
        this.updateStarTaggedMilestoneTotalCount(repoName)
      }
      this.startSyncingMilestoneData()
    },
    updateApiAuthorizationHeader: function (username, password) {
      let token = null
      if (username && password) {
        token = btoa(username + ':' + password)
      }
      this.options = {
        headers: {
          Authorization: 'Basic ' + token
        }
      }
    },
    getUser: function () {
      let url = this.urlRestPrefix + '/user'
      return this.$http.get(url, this.options).then(
      response => {
        return Promise.resolve(response.body)
      }, error => {
        return Promise.reject(error.body)
      })
    },
    getMyOrganizations: function (username) {
      let data = {
        query: `
        query {
          user(login: "{{username}}") {
            organizations(first: 10) {
              nodes {
                login
              }
            }
          }
        }
        `
      }
      data.query = data.query.replace('{{username}}', username)
      return this.$http.post(this.urlGraphql, data, this.options).then(
        response => {
          return Promise.resolve(response.body.data.user.organizations.nodes)
        },
        error => {
          return Promise.reject(error.body)
        }
      )
    },
    getAllMilestones: function (orgLogin) {
      let data = {
        query: `
        query {
          organization(login: "{{orgLogin}}") {
            repositories(first: 50) {
              totalCount
              nodes {
                name
                milestones(last: 10) {
                  totalCount
                  nodes {
                    id
                    title
                    description
                    dueOn
                    state
                    number
                  }
                }
              }
            }
          }
        }
        `
      }
      data.query = data.query.replace('{{orgLogin}}', orgLogin)
      return this.$http.post(this.urlGraphql, data, this.options).then(
        response => {
          return Promise.resolve(response.body.data.organization.repositories.nodes)
        },
        error => {
          return Promise.reject(error.body)
        }
      )
    },
    getRepoMilestones: function (orgLogin, repoName) {
      let url = this.urlRestPrefix + '/repos/' + orgLogin + '/' + repoName + '/milestones'
      return this.$http.get(url, this.options).then(
      response => {
        return Promise.resolve(response.body)
      }, error => {
        return Promise.reject(error.body)
      })
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h2 {
  font-weight: normal;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  display: inline-block;
  margin: 0 10px;
}

a {
  color: #42b983;
}

.button {
  cursor: pointer;
  padding: 1em;
  background-color: hsl(170,0%,90%);
  margin: 1em;
}

.login-container {
  padding: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  position: absolute;
  top: 0;
  left: 0;
}
.login-container .login-input {
  padding: 1em;
  font-size: 1em;
  -webkit-appearance: none;
  border: 1px solid #ddd;
  margin: 0.5em 1em;
  width: 100%;
  max-width: 200px;
}
.login-container .login-btn {
  cursor: pointer;
  padding: 1em;
  background-color: hsl(170,0%,90%);
  margin: 0.5em 1em;
  width: 100%;
  max-width: 200px;
}

.after-login-container {
  padding: 0;
  width: 100%;
  height: 100%;
  position: absolute;
  top: 0;
  left: 0;
  overflow: hidden;
}

.organizations-wrapper {
  padding: 0;
  height: 110px;
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  overflow: hidden;
  z-index: 100;
  background-color: hsla(0,0%,10%,0.7);
}
.organizations-wrapper .instruction-text{
  padding: 1em;
  text-align: left;
  user-select: none;
  color: #fff;
}
.organizations-wrapper .organizations{
  padding: 0;
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: flex-start;
}
.organizations-wrapper .organization-btn{
  text-transform: uppercase;
  cursor: pointer;
  padding: 1em 2em;
  margin: 0 1em;
  background-color: hsl(202,70%,60%);
  color: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.2);
}
.organizations-wrapper .organization-btn:hover{
  background-color: hsl(202,70%,55%);
}
.organizations-wrapper .organization-btn:active{
  background-color: hsl(202,70%,55%);
  box-shadow: 0 0px 2px rgba(0,0,0,0.2);
}

.repositories-wrapper { 
  position: absolute;
  padding-top: 110px;
  padding-bottom: 50px;
  top: 0;
  left: 0px;
  width: 100%;
  height: calc(100% - 110px - 30px);
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
  -ms-overflow-style: ms-autohiding-scrollbar;
}
.repositories-wrapper::-webkit-scrollbar {
    display: none;
}
.repositories-wrapper .no-repository-text { 
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: calc(100% - 110px);
  background-color: #fff;
  position: absolute;
  top: 110px;
  left: 0;
  user-select: none;
}
.repositories-wrapper .repo {
  margin: 1em 0;
  width: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: flex-start;
}
.repositories-wrapper .repo .repo-name{
  font-size: 1.5em;
  margin: 1rem;
}
.repositories-wrapper .repo .no-milestone-text{
  margin: 0.5em 1em;
  padding: 3em 1em;
  width: calc(100% - 4em);
  box-shadow: rgba(0, 0, 0, 0.2) 0px 0px 4px;
}
.repositories-wrapper .repo .milestone-wrapper {
  width: 100%;
}
.repositories-wrapper .repo .milestone{
  margin: 0.5em 1em;
  padding: 1em;
  width: calc(100% - 4em);
  box-shadow: 0 0 4px rgba(0,0,0,0.2);
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: space-between;
  cursor: pointer;
}
.repositories-wrapper .repo .milestone:hover{
  background-color: #fafafa;
}
.repositories-wrapper .repo .milestone .no-info{
  opacity: 0.3;
}
.repositories-wrapper .repo .milestone .info-container{
  text-align: left;
  width: 50%;
  min-width: 200px;
  margin: 1em 0;
}
.repositories-wrapper .repo .milestone .info-container .info-inner-stack{
  text-align: left;
  display: flex;
  flex-direction: row;
  justify-content: flex-start;
  align-items: center;
  height: 30px;
}
.repositories-wrapper .repo .milestone .milestone-title{
  font-size: 1.3em;
  font-weight: bold;
  margin-bottom: 1em;
}
.repositories-wrapper .repo .milestone .milestone-due{
  font-size: 1em;
  margin-bottom: 1em;
}
.repositories-wrapper .repo .milestone .milestone-description{
  font-size: 1em;
}
.repositories-wrapper .repo .milestone .milestone-state{
  font-size: 1em;
}
.repositories-wrapper .repo .milestone .milestone-issues{
  font-size: 1em;
  margin-right: 1em;
  font-weight: bold;
}
.repositories-wrapper .repo .milestone .milestone-bargraph{
  width: 100%;
  height: 100%;
}
.repositories-wrapper .repo .milestone .milestone-bargraph .background{
  width: 100%;
  height: calc(100% - 14px);
  background-color: #eee;
  border-radius: 4px;
  overflow: hidden;
  position: relative;
}
.repositories-wrapper .repo .milestone .milestone-bargraph .foreground{
  width: 100%;
  height: 100%;
  background-color: hsl(202,70%,60%);
  position: absolute;
  top: 0;
  left: 0;
  transform-origin: left;
  transform: scaleX(0);
  transition: transform .3s;
}


.svg-btn-fab {
  position: absolute;
  background: hsl(38, 0%, 20%);
  bottom: 3em;
  right: 1em;
  width: 48px;
  height: 48px;
  z-index: 1000;
  border-radius: 50%;
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0,0,0,0.5);
  color: hsl(38, 0%, 30%);
}
.svg-btn-fab.active {
  color: hsl(38, 100%, 50%);
}
.svg-btn-fab:hover {
  background: hsl(38, 0%, 15%);
}
.svg-btn-fab:active {
  background: hsl(38, 0%, 15%);
  box-shadow: 0 0px 2px rgba(0,0,0,0.5);
}
.svg-btn-fab svg {
  padding: 0;
  width: 36px;
  height: 36px;
  position: absolute;
  top: 50%;
  height: 50%;
  transform: translate(-50%, -50%);
  fill: currentColor;
}

@media screen and (max-width: 480px) {
  .repositories-wrapper .repo .milestone .info-container{
    width: 100%;
  }
}



.fade-enter-active, .fade-leave-active {
  transition: opacity .5s
}
.fade-enter, .fade-leave-to /* .fade-leave-active below version 2.1.8 */ {
  opacity: 0
}
</style>
