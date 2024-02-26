using Godot;
using System;
using System.Speech.Synthesis;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.Collections;

public partial class Speaker : Node {
	public static AudioStreamWav GetKillphraseAudio(string killphrase) {
		AudioStreamWav sound = new() {
			Format = AudioStreamWav.FormatEnum.Format16Bits,
			MixRate = 22050
		};

		try {
			string wordDir = ProjectSettings.GlobalizePath("res://Audio/Speech/");
			string wordpath = wordDir + killphrase + ".wav";
			if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows)) {
				if (System.IO.File.Exists(wordpath)) {
					sound = ResourceLoader.Load<AudioStreamWav>(wordpath);
				} else {
					SpeechSynthesizer ss = new() {
						Volume = 100
					};
					ss.SelectVoiceByHints(VoiceGender.Male, VoiceAge.Adult);

					var audioStream = new System.IO.MemoryStream();
					var formatInfo = new System.Speech.AudioFormat.SpeechAudioFormatInfo(
						22050, System.Speech.AudioFormat.AudioBitsPerSample.Sixteen, System.Speech.AudioFormat.AudioChannel.Mono
					);

					ss.SetOutputToAudioStream(audioStream, formatInfo);
					ss.Speak(killphrase);
					ss.SetOutputToNull();

					byte[] buffer = audioStream.ToArray();
					sound.Data = buffer;
					sound.SaveToWav(wordpath);
				}
			} else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX)) {
				if (System.IO.File.Exists(wordpath)) {
					sound = ResourceLoader.Load<AudioStreamWav>(wordpath);
				} else {
					//TODO: jank as hell
					//make it detect where ffmpeg is and give up if not exists
					string filepath = wordDir + killphrase;
					string voice = "moira";
					var rand = new Random();
					int coinflip = rand.Next()% 2;
					if (coinflip == 0) {
						voice = "daniel";
					}
					var sayProcess = Process.Start("/usr/bin/say","-v " + voice + " -r 150 -o " + filepath + ".ogg" + " " + killphrase);
					sayProcess.WaitForExit();

					var ffmpegProcess = Process.Start("/opt/homebrew/bin/ffmpeg","-i " + filepath + ".ogg -f s16le -acodec pcm_s16le " + filepath + ".raw");
					ffmpegProcess.WaitForExit();

					byte[] buffer = System.IO.File.ReadAllBytes(filepath + ".raw");
					sound.Data = buffer;
					sound.SaveToWav(wordpath);

					var rmTmpProcess = Process.Start("/bin/rm", filepath + ".ogg " + filepath + ".raw");
					rmTmpProcess.WaitForExit();
				}
			}
		} catch (PlatformNotSupportedException _) {
			GD.Print("Platform not supported for Speech Synthesis - get a windows computer, loser.");
		}
		return sound;
	}
}
