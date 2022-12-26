import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';


class HomePage extends StatefulWidget {
  Color color1;
  Color color2;
  HomePage(this.color1, this.color2);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //define onaudioquery
  final OnAudioQuery _audioQuery = OnAudioQuery();
  //define audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  //more variables
  List<SongModel> songs = [];
  List<SongModel> que = [];
  String currentSongTitle = '';
  String sortType = 'title';
  String searchString = '';
  Widget signingOut = Icon(Icons.logout);
  bool isDesc= false;
  int currentIndex = 0;
  bool isPlaying = false;
  bool isShuffle = false;
  TextEditingController searchController = TextEditingController();

  Stream<DurationState> get _durationStateStream =>
    Rx.combineLatest2<Duration, Duration?, DurationState>(
      _audioPlayer.positionStream, _audioPlayer.durationStream, (position, duration) =>DurationState(
        position: position, total: duration?? Duration.zero
      ));

  @override
  void initState() {
    super.initState();
    requestStoragePermission();

    //update the current playing song index listener
    _audioPlayer.currentIndexStream.listen((index){
      if(index != null){
        _updateCurrentPlayingSongDetails(index);
      }
    });
  }

  void _updateCurrentPlayingSongDetails(int index){
    setState(() {
      if(songs.isNotEmpty){
        currentSongTitle = songs[index].title;
        currentIndex = index;
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  BoxDecoration getDecoration() {
    return BoxDecoration(
      color: widget.color1,
      borderRadius: BorderRadius.circular(20),
    );
  }

  //define a method to set the player view visibility
  void _changeIsPlaying(){
    setState(() {
      isPlaying = !isPlaying;    
    });
  } 

  
  void requestStoragePermission() async{
    //if platform is web, we have no permission
    if(!kIsWeb){
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if(!permissionStatus){
        await _audioQuery.permissionsRequest();
      }
      //ensure build method is called
      setState(() {
      });
    } 
  }

  SongSortType sort(String sortType){
    if(sortType == 'file name'){
       return SongSortType.DISPLAY_NAME;
    }
    else if(sortType == 'date added'){
       return SongSortType.DATE_ADDED;
    }
    else if(sortType == 'title'){
      return SongSortType.TITLE;
    }
    else{
      return SongSortType.TITLE;
    }
  }
  
  //create playlist
  ConcatenatingAudioSource createPlaylist(List<SongModel> songs){
    List<AudioSource> sources = [];
    for(var song in songs){ 
      sources.add(AudioSource.uri(Uri.parse(song.uri!)));
    }

    return ConcatenatingAudioSource(children: sources);
  }  


  @override
  Widget build(BuildContext context) {
    if(isPlaying){
      return WillPopScope(
        onWillPop: () async{
          return false;  
        },
        child: Scaffold(
          backgroundColor: widget.color2,
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding:   EdgeInsets.only(top: 40, right: 20.0, left: 20.0),
              decoration: BoxDecoration(color: widget.color2),
              child: Column(
                children: <Widget>[
                  //exit button
                  Row(
                    children: [
                      InkWell(
                        onTap: (){
                          _changeIsPlaying();
                        }, //hides the player view
                        child:  Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                         currentSongTitle,
                         style: GoogleFonts.poppins(
                           color: Colors.white70,
                           fontWeight: FontWeight.bold,
                           fontSize: 20,
                         ),
                         overflow: TextOverflow.fade, maxLines: 1, softWrap: false,
                       ),
                      Text(
                          songs[currentIndex].artist.toString(),
                          style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                          songs[currentIndex].album.toString(),
                          style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                       GestureDetector(
                          onHorizontalDragEnd: (DragEndDetails details) {
                            if (details.primaryVelocity !< 0) {
                              // User swiped Left
                              if(_audioPlayer.hasNext){
                                _audioPlayer.seekToNext();
                              }
                            } else if (details.primaryVelocity !> 0) {
                              // User swiped Right
                              if(_audioPlayer.hasPrevious){
                                _audioPlayer.seekToPrevious();
                              }
                            }
                          },
                         child: Container(
                            width: 300,
                            height: 300,
                            decoration: getDecoration(),
                            margin: const EdgeInsets.only(top: 10, bottom: 10),
                            child: QueryArtworkWidget(
                              id: songs[currentIndex].id,
                              type: ArtworkType.AUDIO,
                              artworkBorder: BorderRadius.circular(20.0),
                            ),
                          ),
                       ),
                        
                      //slider bar container
                      Container(
                        height: 20,
                        margin:   EdgeInsets.only(top: 10,bottom: 10),
      
                        //slider bar duration state stream
                        child: StreamBuilder<DurationState>(
                          stream: _durationStateStream,
                          builder: (context, snapshot){
                            final durationState = snapshot.data;
                            final progress = durationState?.position?? Duration.zero;
                            final total = durationState?.total ?? Duration.zero;
      
                            return ProgressBar(
                              thumbCanPaintOutsideBar: true,
                              progress: progress,
                              total: total,
                              barHeight: 10,
                              baseBarColor: Color.fromARGB(94, 41, 41, 41),
                              progressBarColor:  widget.color1,
                              thumbColor:  Color.fromARGB(95, 194, 194, 194),
                              timeLabelTextStyle: GoogleFonts.poppins(
                                fontSize: 0,
                              ),
                              onSeek: (duration){
                                _audioPlayer.seek(duration);
                              },
                            );
                          },
                        ),
                      ),
      
                      //position /progress and total text
                      StreamBuilder<DurationState>(
                        stream: _durationStateStream,
                        builder: (context, snapshot){
                          final durationState = snapshot.data;
                          final progress = durationState?.position?? Duration.zero;
                          final total = durationState?.total ?? Duration.zero;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Flexible(
                                child: Text(
                                  progress.toString().split(".")[0],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  total.toString().split(".")[0],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  //prev, play/pause & seek next control buttons
                  Container(
                    margin:   EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment:  MainAxisAlignment.center,
                      mainAxisSize:  MainAxisSize.max,
                      children: [
                        //skip to previous
                        Flexible(
                          child: InkWell(
                            onTap: (){
                              if(_audioPlayer.hasPrevious){
                                _audioPlayer.seekToPrevious();
                              }
                            },
                            child: Container(
                              width: 60,
                              decoration:  getDecoration(),
                              padding:   EdgeInsets.all(10.0),
                              child:   Icon(Icons.skip_previous, color: Colors.white70,),
                            ),
                          ),
                        ),
                        //play pause
                        Flexible(
                          child: InkWell(
                            onTap: (){
                              if(_audioPlayer.playing){
                                _audioPlayer.pause();
                              }else{
                                if(_audioPlayer.currentIndex != null){
                                  _audioPlayer.play();
                                }
                              }
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration:  BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.color1,
                              ),
                              padding:   EdgeInsets.all(10.0),
                              margin:   EdgeInsets.only(right: 20.0, left: 20.0),
                              child: StreamBuilder<bool>(
                                stream: _audioPlayer.playingStream,
                                builder: (context, snapshot){
                                  bool? playingState = snapshot.data;
                                  if(playingState != null && playingState){
                                    return   Icon(Icons.pause, size: 30, color: Colors.white70,);
                                  }
                                  return   Icon(Icons.play_arrow, size: 30, color: Colors.white70,);
                                },
                              ),
                            ),
                          ),
                        ),
                        //skip to next
                        Flexible(
                          child: InkWell(
                            onTap: (){
                              if(_audioPlayer.hasNext){
                                _audioPlayer.seekToNext();
                              }
                            },
                            child: Container(
                              width: 60,
                              decoration:  getDecoration(),
                              padding:   EdgeInsets.all(10.0),
                              child:   Icon(Icons.skip_next, color: Colors.white70,),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      
                  Row(
                    mainAxisAlignment:  MainAxisAlignment.center,
                    children:[
                      InkWell(
                        onTap: (){
                          _audioPlayer.setShuffleModeEnabled(true);
                          isShuffle = !isShuffle;
                          setState(() {});
                        },
                        child: Container(
                          width: 60,
                          padding: const EdgeInsets.all(10.0),
                          margin:  const EdgeInsets.only(),
                          decoration:  getDecoration(),
                          child: Icon(Icons.shuffle, color: !isShuffle? Colors.white24 : Colors.white,),
                        ),
                      ),
                      //repeat mode
                      SizedBox(width: 20,),
                      InkWell(
                        onTap: (){
                          _audioPlayer.loopMode == LoopMode.one ? _audioPlayer.setLoopMode(LoopMode.all) : _audioPlayer.setLoopMode(LoopMode.one);
                        },
                        child: Container(
                          width: 60,
                          padding: const EdgeInsets.all(10.0),
                          decoration:  getDecoration(),
                          child: StreamBuilder<LoopMode>(
                            stream: _audioPlayer.loopModeStream,
                            builder: (context, snapshot){
                              final loopMode = snapshot.data;
                              if(LoopMode.one == loopMode){
                                return const Icon(Icons.repeat_one, color: Colors.white70,);
                              }
                              return const Icon(Icons.repeat, color: Colors.white70,);
                            },
                          ),
                        ),
                      ),
                    ]
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: currentSongTitle.isNotEmpty? 150 : 90,
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.black,
          title: Column(
            children: [
              Row(
                children: [
                  Text('Calm Mp3', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  Spacer(),
                  IconButton(
                    onPressed: (){
                      if(sortType == 'file name'){
                        sortType = 'date added';
                      }
                      else if(sortType == 'date added'){
                        sortType = 'title';
                      }
                      else if (sortType == 'title'){
                        sortType = 'file name';
                      }
                      
                      currentSongTitle = '';
                      setState(() {
                      });
                      sort(sortType);
                    }, 
                    icon: Row(
                      children: [
                        Icon(Icons.sort),
                        Text('$sortType', style: GoogleFonts.poppins(fontSize: 15)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      isDesc = !isDesc;
                      currentSongTitle = '';
                      setState(() {
                      });
                    }, 
                    child: Row(
                      children: [
                        Icon(isDesc ? Icons.arrow_drop_down : Icons.arrow_drop_up),
                        Text(isDesc? 'desc' : 'asc', style: GoogleFonts.poppins(fontSize: 15)),
                      ],
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: ()async{
                      setState(() {
                        signingOut = Text('Signing Out',style: GoogleFonts.poppins(fontSize: 10));
                      });
                      await Future.delayed(const Duration(seconds: 1));
                        FirebaseAuth.instance.signOut();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    child: signingOut,
                  ),
                ],
              ),
              Visibility(
                visible: currentSongTitle.isNotEmpty,
                child: GestureDetector(
                  onTap: () => _changeIsPlaying(), 
                  child: Container(
                    padding: EdgeInsets.all(5),
                    height: 60,
                    width: double.infinity,
                    decoration: getDecoration(),
                    child: Column(
                      children: [
                        Center(child: Text(currentSongTitle, style: GoogleFonts.poppins(fontSize: 13),)),
                        Spacer(),
                        Row(
                          mainAxisAlignment:  MainAxisAlignment.center,
                          children: [
                            //skip to previous
                            Flexible(
                              child: InkWell(
                                onTap: (){
                                  if(_audioPlayer.hasPrevious){
                                    _audioPlayer.seekToPrevious();
                                  }
                                },
                                child: Container(
                                  width: 20,
                                  child:   Icon(Icons.skip_previous, color: Colors.white70,),
                                ),
                              ),
                            ),
                            Spacer(),
                            //play pause
                            Flexible(
                              child: InkWell(
                                onTap: (){
                                  if(_audioPlayer.playing){
                                    _audioPlayer.pause();
                                  }else{
                                    if(_audioPlayer.currentIndex != null){
                                      _audioPlayer.play();
                                    }
                                  }
                                },
                                child: Container(
                                  height: 20,
                                  child: StreamBuilder<bool>(
                                    stream: _audioPlayer.playingStream,
                                    builder: (context, snapshot){
                                      bool? playingState = snapshot.data;
                                      if(playingState != null && playingState){
                                        return   Icon(Icons.pause, size: 20, color: Colors.white70,);
                                      }
                                      return   Icon(Icons.play_arrow, size: 20, color: Colors.white70,);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Spacer(),
                            //skip to next
                            Flexible(
                              child: InkWell(
                                onTap: (){
                                  if(_audioPlayer.hasNext){
                                    _audioPlayer.seekToNext();
                                  }
                                },
                                child: Container(
                                  width: 20,
                                  child:   Icon(Icons.skip_next, color: Colors.white70,),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                height: 30,
                width: double.infinity,
                child: TextField(
                  onSubmitted: (String value) {
                    searchString = searchController.text; 
                    setState(() {
                    });
                  },
                  keyboardType: TextInputType.emailAddress,
                  controller: searchController,
                  cursorColor: Colors.white,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'Search',
                    hintStyle: GoogleFonts.raleway(),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: widget.color2,
        ),
        backgroundColor: widget.color2,
        body: FutureBuilder<List<SongModel>>(
          future: _audioQuery.querySongs(
            sortType: sort(sortType),
            orderType: isDesc?  OrderType.DESC_OR_GREATER : OrderType.ASC_OR_SMALLER,
            uriType: UriType.EXTERNAL,
            ignoreCase: true,
          ),
          builder: (context, item) {
            //loading content indicator
            if(item.data == null){
              return   Center(child: SpinKitFadingCube(
                color: Colors.white,
                size: 40,
              ),);
            }
            //no songs found
            if(item.data!.isEmpty){
              return Center(child: Text('No songs found', style: GoogleFonts.poppins()));
            }
            songs.clear();
            songs = item.data!;
            
            return ListView.builder(
              itemCount: item.data!.length,
              itemBuilder: (context, index) {
                return Container(
                  child: searchString.isNotEmpty && !item.data![index].title.toLowerCase().contains(searchString.toLowerCase()) 
                  && !item.data![index].displayNameWOExt.toLowerCase().contains(searchString.toLowerCase())
                  && !item.data![index].artist!.toLowerCase().contains(searchString.toLowerCase())
                   ? null : Container(
                    child: GestureDetector(
                      onTap: () async {
                        _updateCurrentPlayingSongDetails(index);
                        // //show player view
                        _changeIsPlaying();
                        await _audioPlayer.setAudioSource(
                          createPlaylist(item.data!),
                          initialIndex: index
                        );
                        //play the music
                        await _audioPlayer.play();
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 20, bottom: 10),
                        decoration: BoxDecoration(
                          color: widget.color1,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(25),bottomLeft: Radius.circular(25)),
                        ),
                        child: Row(
                          children: [
                            QueryArtworkWidget(
                              artworkHeight: 80,
                              artworkWidth: 100,
                              artworkBorder: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                              nullArtworkWidget: SizedBox(
                                height: 80,
                                width: 100,
                                child: Icon(Icons.album, size: 70, color: Colors.grey,)
                              ),
                              id: item.data![index].id,
                              type: ArtworkType.AUDIO,  
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(item.data![index].title, style: GoogleFonts.poppins(), overflow: TextOverflow.fade, maxLines: 1, softWrap: false,),
                                  Text(item.data![index].artist ?? '<unknown>', style: GoogleFonts.poppins(fontWeight: FontWeight.w100),),                          
                                ]
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        )
      ),
    );
  }
}
//duration class
class DurationState{
  DurationState({this.position = Duration.zero, this.total = Duration.zero});
  Duration position, total;
}
