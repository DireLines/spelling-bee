using Godot;
using System.Speech.Synthesis;

public partial class Speaker : Node
{
	public static AudioStreamWav GetKillphraseAudio(string killphrase) {
		string wordpath = ProjectSettings.GlobalizePath("res://Audio/Speech/" + killphrase + ".wav");
		AudioStreamWav sound = new AudioStreamWav();
		if (!System.IO.File.Exists(wordpath)) {
            SpeechSynthesizer ss = new SpeechSynthesizer
            {
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
			sound.Format = AudioStreamWav.FormatEnum.Format16Bits;
			sound.MixRate = 22050;
			sound.SaveToWav(wordpath);
		} else {
			sound = ResourceLoader.Load<AudioStreamWav>(wordpath);
		}

		return sound;
	}
}
