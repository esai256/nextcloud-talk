<!--
  - @copyright Copyright (c) 2019, Daniel Calviño Sánchez (danxuliu@gmail.com)
  -
  - @license GNU AGPL version 3 or any later version
  -
  - This program is free software: you can redistribute it and/or modify
  - it under the terms of the GNU Affero General Public License as
  - published by the Free Software Foundation, either version 3 of the
  - License, or (at your option) any later version.
  -
  - This program is distributed in the hope that it will be useful,
  - but WITHOUT ANY WARRANTY; without even the implied warranty of
  - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  - GNU Affero General Public License for more details.
  -
  - You should have received a copy of the GNU Affero General Public License
  - along with this program. If not, see <http://www.gnu.org/licenses/>.
  -
  -->
<template>
	<div v-shortkey.push="disableKeyboardShortcuts ? null : ['space']"
		@shortkey="handleShortkey">
		<div class="buttons-bar">
			<div class="network-connection-state">
				<NcPopover v-if="qualityWarningTooltip"
					:boundary="boundaryElement"
					:aria-label="qualityWarningAriaLabel"
					trigger="hover"
					:auto-hide="false"
					:shown="showQualityWarningTooltip">
					<template #trigger>
						<NcButton id="quality_warning_button"
							type="tertiary-no-background"
							class="trigger"
							@click="mouseover = !mouseover">
							<template #icon>
								<NetworkStrength2Alert fill-color="#e9322d"
									:size="20" />
							</template>
						</NcButton>
					</template>
					<div class="hint">
						<span>{{ qualityWarningTooltip.content }}</span>
						<div class="hint__actions">
							<NcButton v-if="qualityWarningTooltip.action"
								type="primary"
								class="hint__button"
								@click="executeQualityWarningTooltipAction">
								{{ qualityWarningTooltip.actionLabel }}
							</NcButton>
							<NcButton v-if="!isQualityWarningTooltipDismissed"
								type="tertiary"
								class="hint__button"
								@click="dismissQualityWarningTooltip">
								{{ t('spreed', 'Dismiss') }}
							</NcButton>
						</div>
					</div>
				</NcPopover>
			</div>
			<div id="muteWrapper">
				<NcButton v-shortkey.once="disableKeyboardShortcuts ? null : ['m']"
					v-tooltip="audioButtonTooltip"
					type="tertiary-no-background"
					:aria-label="audioButtonAriaLabel"
					:class="audioButtonClass"
					@shortkey="toggleAudio"
					@click.stop="toggleAudio">
					<template #icon>
						<Microphone v-if="showMicrophoneOn"
							:size="20"
							fill-color="#ffffff" />
						<MicrophoneOff v-else
							:size="20"
							fill-color="#ffffff" />
					</template>
				</NcButton>
				<span v-show="model.attributes.audioAvailable"
					ref="volumeIndicator"
					class="volume-indicator"
					:class="{'microphone-off': !showMicrophoneOn}" />
			</div>
			<NcButton v-shortkey.once="disableKeyboardShortcuts ? null : ['v']"
				v-tooltip="videoButtonTooltip"
				type="tertiary-no-background"
				:aria-label="videoButtonAriaLabel"
				:class="videoButtonClass"
				@shortkey="toggleVideo"
				@click.stop="toggleVideo">
				<template #icon>
					<VideoIcon v-if="showVideoOn"
						:size="20"
						fill-color="#ffffff" />
					<VideoOff v-else
						:size="20"
						fill-color="#ffffff" />
				</template>
			</NcButton>
			<NcButton v-if="isVirtualBackgroundAvailable && !showActions"
				v-tooltip="toggleVirtualBackgroundButtonLabel"
				type="tertiary-no-background"
				:aria-label="toggleVirtualBackgroundButtonLabel"
				:class="blurButtonClass"
				@click.stop="toggleVirtualBackground">
				<template #icon>
					<Blur v-if="isVirtualBackgroundEnabled"
						:size="20"
						fill-color="#ffffff" />
					<BlurOff v-else
						:size="20"
						fill-color="#ffffff" />
				</template>
			</NcButton>
			<NcActions v-if="!screenSharingButtonHidden"
				id="screensharing-button"
				v-tooltip="screenSharingButtonTooltip"
				:aria-label="screenSharingButtonAriaLabel"
				:class="screenSharingButtonClass"
				class="app-navigation-entry-utils-menu-button"
				:boundaries-element="boundaryElement"
				:container="container"
				:open="screenSharingMenuOpen"
				@update:open="screenSharingMenuOpen = true"
				@update:close="screenSharingMenuOpen = false">
				<!-- Actions button icon -->
				<template #icon>
					<CancelPresentation v-if="model.attributes.localScreen"
						:size="20"
						fill-color="#ffffff" />
					<PresentToAll v-else
						:size="20"
						fill-color="#ffffff" />
				</template>
				<!-- /Actions button icon -->
				<!-- Actions -->
				<NcActionButton v-if="!screenSharingMenuOpen"
					@click.stop="toggleScreenSharingMenu">
					<template #icon>
						<PresentToAll :size="20"
							fill-color="#ffffff" />
					</template>
					{{ screenSharingButtonTooltip }}
				</NcActionButton>
				<NcActionButton v-if="model.attributes.localScreen"
					@click="showScreen">
					<template #icon>
						<Monitor :size="20" />
					</template>
					{{ t('spreed', 'Show your screen') }}
				</NcActionButton>
				<NcActionButton v-if="model.attributes.localScreen"
					@click="stopScreen">
					<template #icon>
						<CancelPresentation :size="20" />
					</template>
					{{ t('spreed', 'Stop screensharing') }}
				</NcActionButton>
			</NcActions>
			<NcButton v-shortkey.once="disableKeyboardShortcuts ? null : ['r']"
				v-tooltip="disableKeyboardShortcuts ? t('spreed', 'Lower hand') : t('spreed', 'Lower hand (R)')"
				type="tertiary-no-background"
				class="lower-hand"
				:class="model.attributes.raisedHand.state ? '' : 'hidden-visually'"
				:tabindex="model.attributes.raisedHand.state ? 0 : -1"
				:aria-label="disableKeyboardShortcuts ? t('spreed', 'Lower hand') : t('spreed', 'Lower hand (R)')"
				@shortkey="toggleHandRaised"
				@click.stop="toggleHandRaised">
				<template #icon>
					<!-- The following icon is much bigger than all the others
							so we reduce its size -->
					<HandBackLeft :size="18"
						fill-color="#ffffff" />
				</template>
			</NcButton>
			<NcActions v-if="showActions"
				v-tooltip="t('spreed', 'More actions')"
				:container="container"
				:aria-label="t('spreed', 'More actions')">
				<template #icon>
					<DotsHorizontal :size="20"
						fill-color="#ffffff" />
				</template>

				<NcActionButton :close-after-click="true"
					@click="toggleHandRaised">
					<!-- The following icon is much bigger than all the others
						so we reduce its size -->
					<template #icon>
						<HandBackLeft :size="18" />
					</template>
					{{ raiseHandButtonLabel }}
				</NcActionButton>
				<NcActionButton v-if="isVirtualBackgroundAvailable"
					:close-after-click="true"
					@click="toggleVirtualBackground">
					<template #icon>
						<BlurOff v-if="isVirtualBackgroundEnabled"
							:size="20" />
						<Blur v-else
							:size="20" />
					</template>
					{{ toggleVirtualBackgroundButtonLabel }}
				</NcActionButton>
				<!-- Call layout switcher -->
				<NcActionButton v-if="isInCall"
					:close-after-click="true"
					@click="changeView">
					<template #icon>
						<GridView v-if="!isGrid"
							:size="20" />
						<PromotedView v-else
							:size="20" />
					</template>
					{{ changeViewText }}
				</NcActionButton>
				<NcActionSeparator />
				<NcActionButton :close-after-click="true"
					@click="showSettings">
					<template #icon>
						<Cog :size="20" />
					</template>
					{{ t('spreed', 'Devices settings') }}
				</NcActionButton>
			</NcActions>
		</div>
	</div>
</template>

<script>
import escapeHtml from 'escape-html'
import { emit } from '@nextcloud/event-bus'
import { showMessage } from '@nextcloud/dialogs'
import CancelPresentation from '../../missingMaterialDesignIcons/CancelPresentation.vue'
import Cog from 'vue-material-design-icons/Cog.vue'
import DotsHorizontal from 'vue-material-design-icons/DotsHorizontal.vue'
import GridView from '../../missingMaterialDesignIcons/GridView.vue'
import HandBackLeft from 'vue-material-design-icons/HandBackLeft.vue'
import Microphone from 'vue-material-design-icons/Microphone.vue'
import MicrophoneOff from 'vue-material-design-icons/MicrophoneOff.vue'
import Monitor from 'vue-material-design-icons/Monitor.vue'
import PresentToAll from '../../missingMaterialDesignIcons/PresentToAll.vue'
import PromotedView from '../../missingMaterialDesignIcons/PromotedView.vue'
import VideoIcon from 'vue-material-design-icons/Video.vue'
import VideoOff from 'vue-material-design-icons/VideoOff.vue'
import Blur from 'vue-material-design-icons/Blur.vue'
import BlurOff from 'vue-material-design-icons/BlurOff.vue'
import NcPopover from '@nextcloud/vue/dist/Components/NcPopover.js'
import NcButton from '@nextcloud/vue/dist/Components/NcButton.js'
import Tooltip from '@nextcloud/vue/dist/Directives/Tooltip.js'
import { PARTICIPANT } from '../../../constants.js'
import SpeakingWhileMutedWarner from '../../../utils/webrtc/SpeakingWhileMutedWarner.js'
import NetworkStrength2Alert from 'vue-material-design-icons/NetworkStrength2Alert.vue'
import NcActions from '@nextcloud/vue/dist/Components/NcActions.js'
import NcActionSeparator from '@nextcloud/vue/dist/Components/NcActionSeparator.js'
import NcActionButton from '@nextcloud/vue/dist/Components/NcActionButton.js'
import { callAnalyzer } from '../../../utils/webrtc/index.js'
import { CONNECTION_QUALITY } from '../../../utils/webrtc/analyzers/PeerConnectionAnalyzer.js'
import isInCall from '../../../mixins/isInCall.js'

export default {

	name: 'LocalMediaControls',

	directives: {
		tooltip: Tooltip,
	},
	components: {
		NetworkStrength2Alert,
		NcPopover,
		NcActions,
		NcActionSeparator,
		NcActionButton,
		NcButton,
		CancelPresentation,
		Cog,
		DotsHorizontal,
		GridView,
		HandBackLeft,
		Microphone,
		MicrophoneOff,
		PresentToAll,
		PromotedView,
		VideoIcon,
		VideoOff,
		Monitor,
		Blur,
		BlurOff,
	},

	mixins: [
		isInCall,
	],

	props: {
		token: {
			type: String,
			required: true,
		},
		model: {
			type: Object,
			required: true,
		},
		localCallParticipantModel: {
			type: Object,
			required: true,
		},
		screenSharingButtonHidden: {
			type: Boolean,
			default: false,
		},
		showActions: {
			type: Boolean,
			default: true,
		},

		/**
		 * In the sidebar the conversation settings are hidden
		 */
		isSidebar: {
			type: Boolean,
			default: false,
		},
	},

	data() {
		return {
			mounted: false,
			speakingWhileMutedNotification: null,
			screenSharingMenuOpen: false,
			boundaryElement: document.querySelector('.main-view'),
			mouseover: false,
			callAnalyzer,
			qualityWarningInGracePeriodTimeout: null,
			audioEnabledBeforeSpacebarKeydown: undefined,
			spacebarKeyDown: false,
		}
	},

	computed: {
		raiseHandButtonLabel() {
			if (!this.model.attributes.raisedHand.state) {
				if (this.disableKeyboardShortcuts) {
					return t('spreed', 'Raise hand')
				}
				return t('spreed', 'Raise hand (R)')
			}
			if (this.disableKeyboardShortcuts) {
				return t('spreed', 'Lower hand')
			}
			return t('spreed', 'Lower hand (R)')
		},

		isVirtualBackgroundAvailable() {
			return this.model.attributes.virtualBackgroundAvailable
		},

		isVirtualBackgroundEnabled() {
			return this.model.attributes.virtualBackgroundEnabled
		},

		toggleVirtualBackgroundButtonLabel() {
			if (!this.isVirtualBackgroundEnabled) {
				return t('spreed', 'Blur background')
			}
			return t('spreed', 'Disable background blur')
		},

		conversation() {
			return this.$store.getters.conversation(this.token) || this.$store.getters.dummyConversation
		},

		isAudioAllowed() {
			return this.conversation.permissions & PARTICIPANT.PERMISSIONS.PUBLISH_AUDIO
		},

		isVideoAllowed() {
			return this.conversation.permissions & PARTICIPANT.PERMISSIONS.PUBLISH_VIDEO
		},

		isScreensharingAllowed() {
			return this.conversation.permissions & PARTICIPANT.PERMISSIONS.PUBLISH_SCREEN
		},

		audioButtonClass() {
			return {
				'audio-enabled': this.isAudioAllowed && this.model.attributes.audioAvailable && this.model.attributes.audioEnabled,
				'no-audio-available': !this.isAudioAllowed || !this.model.attributes.audioAvailable,
			}
		},

		showMicrophoneOn() {
			return this.model.attributes.audioAvailable && this.model.attributes.audioEnabled
		},

		audioButtonTooltip() {
			if (!this.isAudioAllowed) {
				return t('spreed', 'You are not allowed to enable audio')
			}

			if (!this.model.attributes.audioAvailable) {
				return {
					content: t('spreed', 'No audio'),
					show: false,
				}
			}

			if (this.speakingWhileMutedNotification && !this.screenSharingMenuOpen) {
				return {
					content: this.speakingWhileMutedNotification,
					show: true,
				}
			}

			let content = ''
			if (this.model.attributes.audioEnabled) {
				if (this.disableKeyboardShortcuts) {
					content = t('spreed', 'Mute audio')
				} else {
					content = t('spreed', 'Mute audio (M)')
				}
			} else {
				if (this.disableKeyboardShortcuts) {
					content = t('spreed', 'Unmute audio')
				} else {
					content = t('spreed', 'Unmute audio (M)')
				}
			}

			return {
				content,
				show: false,
			}
		},

		audioButtonAriaLabel() {
			if (!this.model.attributes.audioAvailable) {
				return t('spreed', 'No audio')
			}
			return this.model.attributes.audioEnabled ? t('spreed', 'Mute audio') : t('spreed', 'Unmute audio')
		},

		currentVolumeProportion() {
			// refs can not be accessed on the initial render, only after the
			// component has been mounted.
			if (!this.mounted) {
				return 0
			}

			// WebRTC volume goes from -100 (silence) to 0 (loudest sound in the
			// system); for the volume indicator only sounds above the threshold
			// are taken into account.
			let currentVolumeProportion = 0
			if (this.model.attributes.currentVolume > this.model.attributes.volumeThreshold) {
				currentVolumeProportion = (this.model.attributes.volumeThreshold - this.model.attributes.currentVolume) / this.model.attributes.volumeThreshold
			}

			return currentVolumeProportion
		},

		videoButtonClass() {
			return {
				'video-enabled': this.isVideoAllowed && this.model.attributes.videoAvailable && this.model.attributes.videoEnabled,
				'no-video-available': !this.isVideoAllowed || !this.model.attributes.videoAvailable,
			}
		},

		blurButtonClass() {
			return {
				'blur-disabled': this.isVirtualBackgroundEnabled,
			}
		},

		showVideoOn() {
			return this.model.attributes.videoAvailable && this.model.attributes.videoEnabled
		},

		videoButtonTooltip() {
			if (!this.isVideoAllowed) {
				return t('spreed', 'You are not allowed to enable video')
			}

			if (!this.model.attributes.videoAvailable) {
				return t('spreed', 'No camera')
			}

			if (this.model.attributes.videoEnabled) {
				if (this.disableKeyboardShortcuts) {
					return t('spreed', 'Disable video')
				}

				return t('spreed', 'Disable video (V)')
			}

			if (!this.model.getWebRtc() || !this.model.getWebRtc().connection || this.model.getWebRtc().connection.getSendVideoIfAvailable()) {
				if (this.disableKeyboardShortcuts) {
					return t('spreed', 'Enable video')
				}

				return t('spreed', 'Enable video (V)')
			}

			if (this.disableKeyboardShortcuts) {
				return t('spreed', 'Enable video - Your connection will be briefly interrupted when enabling the video for the first time')
			}

			return t('spreed', 'Enable video (V) - Your connection will be briefly interrupted when enabling the video for the first time')
		},

		videoButtonAriaLabel() {
			if (!this.model.attributes.videoAvailable) {
				return t('spreed', 'No camera')
			}

			if (this.model.attributes.videoEnabled) {
				return t('spreed', 'Disable video')
			}

			if (!this.model.getWebRtc() || !this.model.getWebRtc().connection || this.model.getWebRtc().connection.getSendVideoIfAvailable()) {
				return t('spreed', 'Enable video')
			}

			return t('spreed', 'Enable video. Your connection will be briefly interrupted when enabling the video for the first time')
		},

		screenSharingButtonClass() {
			return {
				'screensharing-enabled': this.isScreensharingAllowed && this.model.attributes.localScreen,
				'no-screensharing-available': !this.isScreensharingAllowed,
			}
		},

		screenSharingButtonTooltip() {
			if (!this.isScreensharingAllowed) {
				return t('spreed', 'You are not allowed to enable screensharing')
			}

			if (this.screenSharingMenuOpen) {
				return null
			}

			if (!this.isScreensharingAllowed) {
				return t('spreed', 'No screensharing')
			}

			return this.model.attributes.localScreen ? t('spreed', 'Screensharing options') : t('spreed', 'Enable screensharing')
		},

		screenSharingButtonAriaLabel() {
			if (this.screenSharingMenuOpen) {
				return ''
			}

			return this.model.attributes.localScreen ? t('spreed', 'Screensharing options') : t('spreed', 'Enable screensharing')
		},

		container() {
			return this.$store.getters.getMainContainerSelector()
		},

		isQualityWarningTooltipDismissed() {
			return this.$store.getters.isQualityWarningTooltipDismissed
		},

		showQualityWarningTooltip() {
			return this.qualityWarningTooltip && (!this.isQualityWarningTooltipDismissed || this.mouseover)
		},

		showQualityWarning() {
			return this.senderConnectionQualityIsBad || this.qualityWarningInGracePeriodTimeout
		},

		senderConnectionQualityIsBad() {
			return this.senderConnectionQualityAudioIsBad
				|| this.senderConnectionQualityVideoIsBad
				|| this.senderConnectionQualityScreenIsBad
		},

		senderConnectionQualityAudioIsBad() {
			return callAnalyzer
				&& (callAnalyzer.attributes.senderConnectionQualityAudio === CONNECTION_QUALITY.VERY_BAD
				 || callAnalyzer.attributes.senderConnectionQualityAudio === CONNECTION_QUALITY.NO_TRANSMITTED_DATA)
		},

		senderConnectionQualityVideoIsBad() {
			return callAnalyzer
				&& (callAnalyzer.attributes.senderConnectionQualityVideo === CONNECTION_QUALITY.VERY_BAD
				 || callAnalyzer.attributes.senderConnectionQualityVideo === CONNECTION_QUALITY.NO_TRANSMITTED_DATA)
		},

		senderConnectionQualityScreenIsBad() {
			return callAnalyzer
				&& (callAnalyzer.attributes.senderConnectionQualityScreen === CONNECTION_QUALITY.VERY_BAD
				 || callAnalyzer.attributes.senderConnectionQualityScreen === CONNECTION_QUALITY.NO_TRANSMITTED_DATA)
		},

		qualityWarningAriaLabel() {
			let label = ''
			if (!this.model.attributes.audioEnabled && this.model.attributes.videoEnabled && this.model.attributes.localScreen) {
				label = t('spreed', 'Bad sent video and screen quality.')
			} else if (!this.model.attributes.audioEnabled && this.model.attributes.localScreen) {
				label = t('spreed', 'Bad sent screen quality.')
			} else if (!this.model.attributes.audioEnabled && this.model.attributes.videoEnabled) {
				label = t('spreed', 'Bad sent video quality.')
			} else if (this.model.attributes.videoEnabled && this.model.attributes.localScreen) {
				label = t('spreed', 'Bad sent audio, video and screen quality.')
			} else if (this.model.attributes.localScreen) {
				label = t('spreed', 'Bad sent audio and screen quality.')
			} else if (this.model.attributes.videoEnabled) {
				label = t('spreed', 'Bad sent audio and video quality.')
			} else {
				label = t('spreed', 'Bad sent audio quality.')
			}

			return label
		},

		qualityWarningTooltip() {
			if (!this.showQualityWarning) {
				return null
			}

			const virtualBackgroundEnabled = this.isVirtualBackgroundAvailable && this.model.attributes.virtualBackgroundEnabled

			const tooltip = {}
			if (!this.model.attributes.audioEnabled && this.model.attributes.videoEnabled && virtualBackgroundEnabled && this.model.attributes.localScreen) {
				tooltip.content = t('spreed', 'Your internet connection or computer are busy and other participants might be unable to see your screen. To improve the situation try to disable the background blur or your video while doing a screen share.')
				tooltip.actionLabel = t('spreed', 'Disable background blur')
				tooltip.action = 'disableVirtualBackground'
			} else if (!this.model.attributes.audioEnabled && this.model.attributes.videoEnabled && this.model.attributes.localScreen) {
				tooltip.content = t('spreed', 'Your internet connection or computer are busy and other participants might be unable to see your screen. To improve the situation try to disable your video while doing a screenshare.')
				tooltip.actionLabel = t('spreed', 'Disable video')
				tooltip.action = 'disableVideo'
			} else if (!this.model.attributes.audioEnabled && this.model.attributes.localScreen) {
				tooltip.content = t('spreed', 'Your internet connection or computer are busy and other participants might be unable to see your screen.')
				tooltip.actionLabel = ''
				tooltip.action = ''
			} else if (!this.model.attributes.audioEnabled && this.model.attributes.videoEnabled) {
				tooltip.content = t('spreed', 'Your internet connection or computer are busy and other participants might be unable to see you.')
				tooltip.actionLabel = ''
				tooltip.action = ''
			} else if (this.model.attributes.videoEnabled && virtualBackgroundEnabled && this.model.attributes.localScreen) {
				tooltip.content = t('spreed', 'Your internet connection or computer are busy and other participants might be unable to understand and see you. To improve the situation try to disable the background blur or your video while doing a screenshare.')
				tooltip.actionLabel = t('spreed', 'Disable background blur')
				tooltip.action = 'disableVirtualBackground'
			} else if (this.model.attributes.videoEnabled && this.model.attributes.localScreen) {
				tooltip.content = t('spreed', 'Your internet connection or computer are busy and other participants might be unable to understand and see you. To improve the situation try to disable your video while doing a screenshare.')
				tooltip.actionLabel = t('spreed', 'Disable video')
				tooltip.action = 'disableVideo'
			} else if (this.model.attributes.localScreen) {
				tooltip.content = t('spreed', 'Your internet connection or computer are busy and other participants might be unable to understand you and see your screen. To improve the situation try to disable your screenshare.')
				tooltip.actionLabel = t('spreed', 'Disable screenshare')
				tooltip.action = 'disableScreenShare'
			} else if (this.model.attributes.videoEnabled && virtualBackgroundEnabled) {
				tooltip.content = t('spreed', 'Your internet connection or computer are busy and other participants might be unable to understand and see you. To improve the situation try to disable the background blur or your video.')
				tooltip.actionLabel = t('spreed', 'Disable background blur')
				tooltip.action = 'disableVirtualBackground'
			} else if (this.model.attributes.videoEnabled) {
				tooltip.content = t('spreed', 'Your internet connection or computer are busy and other participants might be unable to understand and see you. To improve the situation try to disable your video.')
				tooltip.actionLabel = t('spreed', 'Disable video')
				tooltip.action = 'disableVideo'
			} else {
				tooltip.content = t('spreed', 'Your internet connection or computer are busy and other participants might be unable to understand you.')
				tooltip.actionLabel = ''
				tooltip.action = ''
			}

			return tooltip
		},

		changeViewText() {
			if (this.isGrid) {
				return t('spreed', 'Speaker view')
			} else {
				return t('spreed', 'Grid view')
			}
		},

		isGrid() {
			return this.$store.getters.isGrid
		},

		disableKeyboardShortcuts() {
			return OCP.Accessibility.disableKeyboardShortcuts()
		},
	},

	watch: {
		currentVolumeProportion() {
			// The volume meter is updated directly in the DOM as it is
			// more efficient than relying on Vue.js to animate the style property,
			// because the latter would also process all neighboring components repeatedly.
			this.updateVolumeMeter()
		},

		senderConnectionQualityIsBad(senderConnectionQualityIsBad) {
			if (!senderConnectionQualityIsBad) {
				return
			}

			if (this.qualityWarningInGracePeriodTimeout) {
				window.clearTimeout(this.qualityWarningInGracePeriodTimeout)
			}

			this.qualityWarningInGracePeriodTimeout = window.setTimeout(() => {
				this.qualityWarningInGracePeriodTimeout = null
			}, 10000)
		},
	},

	mounted() {
		this.mounted = true
		this.updateVolumeMeter()

		this.speakingWhileMutedWarner = new SpeakingWhileMutedWarner(this.model, this)
	},

	beforeDestroy() {
		this.speakingWhileMutedWarner.destroy()
	},

	methods: {
		updateVolumeMeter() {
			if (!this.mounted) {
				return
			}

			const volumeIndicatorStyle = window.getComputedStyle ? getComputedStyle(this.$refs.volumeIndicator, null) : this.$refs.volumeIndicator.currentStyle
			const maximumVolumeIndicatorHeight = this.$refs.volumeIndicator.parentElement.clientHeight - (parseInt(volumeIndicatorStyle.bottom, 10) * 2)

			// round up to avoid property changes
			const height = Math.floor(maximumVolumeIndicatorHeight * this.currentVolumeProportion)
			this.$refs.volumeIndicator.style.height = height + 'px'
		},

		showSettings() {
			emit('show-settings')
		},

		/**
		 * This method executes on spacebar keydown and keyup
		 */
		handleShortkey() {
			if (!this.model.attributes.audioAvailable) {
				return
			}

			if (!this.spacebarKeyDown) {
				this.audioEnabledBeforeSpacebarKeydown = this.model.attributes.audioEnabled
				this.spacebarKeyDown = true
				this.toggleAudio()
			} else {
				this.spacebarKeyDown = false
				if (this.audioEnabledBeforeSpacebarKeydown) {
					this.model.enableAudio()
				} else {
					this.model.disableAudio()
				}
				this.audioEnabledBeforeSpacebarKeydown = undefined
			}

		},

		toggleAudio() {
			if (!this.model.attributes.audioAvailable) {
				return
			}

			if (this.model.attributes.audioEnabled) {
				this.model.disableAudio()
			} else {
				this.model.enableAudio()
			}
		},

		setSpeakingWhileMutedNotification(message) {
			this.speakingWhileMutedNotification = message
		},

		toggleVideo() {
			/**
			 * Abort toggling the video if the 'v' key is lifted when pasting an
			 * image in the new message form.
			 */
			if (document.getElementsByClassName('upload-editor').length !== 0) {
				return
			}

			if (!this.model.attributes.videoAvailable) {
				return
			}

			if (this.model.attributes.videoEnabled) {
				this.model.disableVideo()
			} else {
				this.model.enableVideo()
			}
		},

		toggleVirtualBackground() {
			if (this.model.attributes.virtualBackgroundEnabled) {
				this.model.disableVirtualBackground()
			} else {
				this.model.enableVirtualBackground()
			}
		},

		toggleScreenSharingMenu() {
			if (!this.isScreensharingAllowed) {
				return
			}

			if (!this.model.getWebRtc().capabilities.supportScreenSharing) {
				if (window.location.protocol === 'https:') {
					showMessage(t('spreed', 'Screen sharing is not supported by your browser.'))
				} else {
					showMessage(t('spreed', 'Screen sharing requires the page to be loaded through HTTPS.'))
				}
				return
			}

			if (this.model.attributes.localScreen) {
				this.screenSharingMenuOpen = !this.screenSharingMenuOpen
			} else {
				this.startShareScreen()
			}
		},

		toggleHandRaised() {
			const state = !this.model.attributes.raisedHand?.state
			this.model.toggleHandRaised(state)
			this.$store.dispatch(
				'setParticipantHandRaised',
				{
					sessionId: this.$store.getters.getSessionId(),
					raisedHand: this.model.attributes.raisedHand,
				}
			)
		},

		showScreen() {
			if (this.model.attributes.localScreen) {
				emit('switch-screen-to-id', this.localCallParticipantModel.attributes.peerId)
			}

			this.screenSharingMenuOpen = false
		},

		stopScreen() {
			this.model.stopSharingScreen()

			this.screenSharingMenuOpen = false
		},

		startShareScreen(mode) {
			this.model.shareScreen(mode, function(err) {
				if (!err) {
					return
				}

				let extensionURL = null

				switch (err.name) {
				case 'HTTPS_REQUIRED':
					showMessage(t('spreed', 'Screensharing requires the page to be loaded through HTTPS.'))
					break
				case 'PERMISSION_DENIED':
				case 'NotAllowedError':
				case 'CEF_GETSCREENMEDIA_CANCELED': // Experimental, may go away in the future.
					break
				case 'FF52_REQUIRED':
					showMessage(t('spreed', 'Sharing your screen only works with Firefox version 52 or newer.'))
					break
				case 'EXTENSION_UNAVAILABLE':
					if (window.chrome) { // Chrome
						extensionURL = 'https://chrome.google.com/webstore/detail/screensharing-for-nextclo/kepnpjhambipllfmgmbapncekcmabkol'
					}

					if (extensionURL) {
						const text = t('spreed', 'Screensharing extension is required to share your screen.')
						const element = '<a href="' + extensionURL + '" target="_blank">' + escapeHtml(text) + '</a>'

						showMessage(element, { isHTML: true })
					} else {
						showMessage(t('spreed', 'Please use a different browser like Firefox or Chrome to share your screen.'))
					}
					break
				default:
					showMessage(t('spreed', 'An error occurred while starting screensharing.'))
					break
				}
			})
		},

		executeQualityWarningTooltipAction() {
			if (this.qualityWarningTooltip.action === '') {
				return
			}
			if (this.qualityWarningTooltip.action === 'disableScreenShare') {
				this.model.stopSharingScreen()
				this.dismissQualityWarningTooltip()
			} else if (this.qualityWarningTooltip.action === 'disableVirtualBackground') {
				this.model.disableVirtualBackground()
				this.dismissQualityWarningTooltip()
			} else if (this.qualityWarningTooltip.action === 'disableVideo') {
				this.model.disableVideo()
				this.dismissQualityWarningTooltip()
			}
		},

		dismissQualityWarningTooltip() {
			this.$store.dispatch('dismissQualityWarningTooltip')
		},

		changeView() {
			this.$store.dispatch('setCallViewMode', { isGrid: !this.isGrid })
			this.$store.dispatch('selectedVideoPeerId', null)
		},
	},
}
</script>

<style lang="scss" scoped>
@import '../../../assets/variables';

.buttons-bar {
	display: flex;
	align-items: center;
}

.buttons-bar button.lower-hand.hidden-visually {
	position: absolute;
	left: -10000px;
	top: -10000px;
	width: 1px;
	height: 1px;
	overflow: hidden;
}

.buttons-bar #screensharing-menu button {
	width: 100%;
	height: auto;
}

/* Highlight the media buttons when enabled */
.buttons-bar button.audio-enabled,
.buttons-bar button.video-enabled,
.buttons-bar button.screensharing-enabled {
	opacity: 1;
}

.buttons-bar button.no-audio-available,
.buttons-bar button.no-video-available,
.buttons-bar button.no-screensharing-available {
	&, & * {
		opacity: .7;
		cursor: not-allowed;
	}
}

#muteWrapper {
	display: inline-block;

	/* Make the wrapper the positioning context of the volume indicator. */
	position: relative;
}

#muteWrapper .volume-indicator {
	position: absolute;

	width: 3px;
	right: 0;

	/* The button height is 44px; the volume indicator button is 36px at
	* maximum, but its value will be changed based on the current volume; the
	* height change will reveal more or less of the gradient, which has
	* absolute dimensions and thus does not change when the height changes. */
	height: 36px;
	bottom: 4px;

	background: linear-gradient(0deg, green, yellow, red 36px);

	opacity: 0.7;

	&.microphone-off {
		background: linear-gradient(0deg, gray, white 36px);
	}
}

.hint {
	padding: 12px;
	max-width: 300px;
	text-align: left;
	&__actions {
		display: flex;
		flex-direction: row-reverse;
		justify-content: space-between;
		padding-top:4px;
	}
	&__button {
		height: $clickable-area;
	}
}

.trigger {
	display: flex;
	align-items: center;
	justify-content: center;
}
</style>
