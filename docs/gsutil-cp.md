cp-复制文件和对象
概要
gsutil cp [OPTION]... src_url dst_url
gsutil cp [OPTION]... src_url... dst_url
gsutil cp [OPTION]... -I dst_url

描述
gsutil cp命令允许您在本地文件系统和云之间复制数据，在云内部复制数据以及在云存储提供程序之间复制数据。例如，要将所有文本文件从本地目录上传到存储桶，您可以执行以下操作：

gsutil cp *.txt gs://my-bucket

同样，您可以执行以下操作从存储桶中下载文本文件：

gsutil cp gs://my-bucket/*.txt .

如果要复制整个目录树，则需要使用-r选项。例如，要上载目录树“ dir”：

gsutil cp -r dir gs://my-bucket

如果要传输大量文件，则可能要使用顶级gsutil -m选项（请参阅gsutil帮助选项）来执行并行（多线程/多处理）副本：

gsutil -m cp -r dir gs://my-bucket

您可以使用-I选项传递URL列表（每行一个）以在stdin上复制而不是作为命令行参数。这使您可以在管道中使用gsutil来上传或下载程序生成的文件/对象，例如：

some_program | gsutil -m cp -I gs://my-bucket

要么：

some_program | gsutil -m cp -I ./download_dir

stdin的内容可以命名文件，云URL以及文件和云URL的通配符。

注意：Shell（例如bash，zsh）有时会尝试以令人惊讶的方式扩展通配符。另外，尝试复制名称中包含通配符的文件可能会导致问题。有关这些问题的更多详细信息，请参见gsutil帮助通配符下的“使用WILDCARD时可能出现的行为”一节。
名称的构造方式
gsutil cp命令努力以与Linux cp的工作方式一致的方式来命名对象，这导致以不同的方式构造名称，具体取决于您是执行递归目录复制还是复制单独命名的对象。以及您是复制到现有目录还是不存在的目录。

在执行递归目录副本时，将构造对象名称，这些对象名称将从递归处理点开始镜像源目录结构。例如，如果dir1 / dir2包含文件a / b / c，则命令：

gsutil cp -r dir1/dir2 gs://my-bucket

将创建对象gs：// my-bucket / dir2 / a / b / c。

相反，复制单独命名的文件将导致对象由源文件的最终路径组件命名。例如，再次假设dir1 / dir2包含a / b / c，则命令：

gsutil cp dir1/dir2/** gs://my-bucket

将创建对象gs：// my-bucket / c。

相同的规则适用于下载：存储桶和存储桶子目录的递归副本生成镜像的文件名结构，而单独复制（或通配符）命名对象则生成统一命名的文件。

请注意，在上面的示例中，“ **”通配符匹配dir下任何位置的所有名称。通配符“ *”将只与一级名称匹配。有关更多详细信息，请参见gsutil帮助通配符。

使用子目录时，还会有另外的麻烦：产生的名称取决于目标子目录是否存在。例如，如果gs：// my-bucket / subdir作为子目录存在，则命令：

gsutil cp -r dir1/dir2 gs://my-bucket/subdir

将创建对象gs：// my-bucket / subdir / dir2 / a / b / c。相反，如果gs：// my-bucket / subdir不存在，则同一gsutil cp命令将创建对象gs：// my-bucket / subdir / a / b / c。

注意：如果您使用 Google Cloud Platform Console 创建文件夹，则可以通过创建以“ /”字符结尾的“占位符”对象来实现。从云下载到本地文件系统时，gsutil会跳过这些对象，因为在Linux和macOS上不允许尝试创建以“ /”结尾的文件。因此，建议您不要创建以“ /”结尾的对象（除非您无需能够使用gsutil下载此类对象）。
复制到/来自子目录；跨机器分配转移
您可以通过以下命令使用gsutil在子目录之间来回复制：

gsutil cp -r dir gs://my-bucket/data

这将导致dir及其所有文件和嵌套子目录复制到指定的目标位置，从而导致对象的名称类似于gs：// my-bucket / data / dir / a / b / c。同样，您可以使用以下命令从存储桶子目录下载：

gsutil cp -r gs://my-bucket/data dir

这将导致嵌套在gs：// my-bucket / data下的所有内容都下载到dir中，从而导致文件名为dir / data / a / b / c。

如果要随着时间将数据添加到现有存储桶目录结构中，则复制子目录很有用。如果您要在多台计算机上并行上载和下载，这也很有用（与在一台计算机上简单运行gsutil -m cp相比，有可能减少总体传输时间）。例如，如果您的存储桶包含以下结构：

gs://my-bucket/data/result_set_01/
gs://my-bucket/data/result_set_02/
...
gs://my-bucket/data/result_set_99/

您可以通过分别在每台计算机上运行以下命令来在3台计算机上执行并发下载：

gsutil -m cp -r gs://my-bucket/data/result_set_[0-3]* dir
gsutil -m cp -r gs://my-bucket/data/result_set_[4-6]* dir
gsutil -m cp -r gs://my-bucket/data/result_set_[7-9]* dir

注意，dir可以是每台计算机上的本地目录，也可以是从共享文件服务器挂载的目录。后者的性能是否令人满意取决于许多因素，因此我们建议尝试找出最适合您的计算环境的方法。

在云中复制和保留元数据
如果源URL和目标URL都是来自同一提供程序的云URL，则gsutil会“在云中”复制数据（即，无需在运行gsutil的计算机上进行下载和上传）。除了这样做的性能和成本优势外，在云中进行复制还可以保留元数据（例如Content-Type和Cache-Control）。相反，当您从云中下载数据时，它将最终存储在一个文件中，该文件没有关联的元数据。因此，除非您有某种方法可以保留或重新创建该元数据，否则下载到文件将不会保留元数据。

跨越位置和/或存储类别的副本会导致数据在云中被重写，这可能会花费一些时间（但仍然比下载和重新上传要快）。如果这些操作被中断，只要它们的命令参数相同，就可以用相同的命令恢复。

请注意，默认情况下，gsutil cp命令不会将对象ACL复制到新对象，而是将使用默认存储桶ACL（请参见 gsutil help defacl）。您可以使用-p选项覆盖此行为（请参见下面的选项）。

关于在云端复制的其他注意事项：如果目标存储桶已启用版本控制，则默认情况下，gsutil cp将仅复制源对象的实时版本。例如：

gsutil cp gs://bucket1/obj gs://bucket2

即使存在gs：// bucket1 / obj的非当前版本，也只会将gs：// bucket1 / obj的单个实时版本复制到gs：// bucket2。要也复制非当前版本，请使用-A标志：

gsutil cp -A gs://bucket1/obj gs://bucket2

使用cp -A标志时，不允许使用顶层gsutil -m标志，以确保保留版本顺序。

校验和验证
在每次上载或下载结束时，gsutil cp命令都会验证它为源文件/对象计算的校验和是否与服务计算的校验和匹配。如果校验和不匹配，gsutil将删除损坏的对象并显示警告消息。这种情况很少发生，但如果发生这种情况，请联系gs-team@google.com。

如果在上传之前知道文件的MD5，则可以在Content-MD5标头中指定该文件，如果MD5与该服务计算的值不匹配，这将导致云存储服务拒绝上传。例如：

% gsutil hash obj
Hashing     obj:
Hashes [base64] for obj:
        Hash (crc32c):          lIMoIw==
        Hash (md5):             VgyllJgiiaRAbyUUIqDMmw==

% gsutil -h Content-MD5:VgyllJgiiaRAbyUUIqDMmw== cp obj gs://your-bucket/obj
Copying file://obj [Content-Type=text/plain]...
Uploading   gs://your-bucket/obj:                                182 b/182 B

If the checksum didn't match the service would instead reject the upload and
gsutil would print a message like:

BadRequestException: 400 Provided MD5 hash "VgyllJgiiaRAbyUUIqDMmw=="
doesn't match calculated MD5 hash "7gyllJgiiaRAbyUUIqDMmw==".

即使您不执行此操作，如果计算出的校验和不匹配，gsutil也会删除该对象，但是指定Content-MD5标头有几个优点：

它可以防止损坏的对象完全可见，否则，在gsutil删除它之前，它会在1-3秒内可见。
如果已经存在具有给定名称的对象，则指定Content-MD5标头将使现有对象永远不会被替换，否则它将被损坏的对象替换，然后在几秒钟后删除。
它将确定地防止损坏的对象留在云中，而如果gsutil进程在上载和删除请求之间进行了^ C处理，则上载完成后删除的gsutil方法可能会失败。
它支持客户到服务的完整性检查切换。例如，如果您有一个内容生产管道可以生成要与该数据的校验和一起上传到云的数据，则在运行gsutil cp时指定由内容管道计算出的MD5将确保校验和始终与之匹配。过程（例如，检测在内容管道写入数据到上载到Cloud Storage的时间之间，本地磁盘上的数据是否损坏）。
注意：对于复合对象，将忽略Content-MD5标头，因为此类对象仅具有CRC32C校验和。
重试处理
发生故障时，cp命令将重试，但是如果在特定的复制或删除操作期间发生了足够的故障，则cp命令将跳过该对象并继续前进。在复制运行结束时，如果未成功重试任何故障，则cp命令将报告故障计数，并以非零状态退出。

请注意，在某些情况下，重试将永远不会成功，例如您没有对目标存储桶的写权限，或者某些对象的目标路径长于最大允许长度。

有关gsutil的重试处理的更多详细信息，请参阅 gsutil帮助重试。

可恢复转账
每当您使用cp命令上传大于8 MiB的对象时，gsutil都会自动执行可恢复的上传。您无需指定任何特殊的命令行选项即可实现此目的。如果您的上传中断，则可以通过运行与开始上传相同的cp命令来重新启动上传。在成功完成上载之前，它在目标对象上将不可见，并且不会替换上载要覆盖的任何现有对象。但是，请参阅关于并行复合上载的部分，这可能会在上载过程中将临时组件对象保留在原位。

同样，除非目标是流，否则只要您使用cp命令，gsutil都会自动执行可恢复的下载（使用标准的HTTP Range GET操作）。在这种情况下，部分下载的临时文件将在目标目录中可见。完成后，原始文件将被删除并被下载的内容覆盖。

可恢复的上载和下载状态信息存储在〜/ .gsutil下的文件中，由目标对象或文件命名。如果您尝试从具有不同目录的计算机上继续传输，则传输将从头开始。

有关在生产环境中使用可恢复传输的详细信息，另请参见gsutil帮助产品。

流传输
使用“-”代替src_url或dst_url来执行流传输。例如：

long_running_computation | gsutil cp - gs://my-bucket/obj

使用JSON API的流式上传（请参阅gsutil帮助apis）在内存中部分缓冲到文件中，因此可以在网络或服务出现问题时重试。

使用XML API的流传输不支持可恢复的上载/下载。如果您要上传大量数据（例如，超过100 MiB），建议您将数据写入本地文件，然后将该文件复制到云中而不是流式传输（对于大型下载也是如此）。

警告：在执行与Cloud Storage之间的流传输时，Cloud Storage和gsutil均不会计算校验和。如果需要数据验证，请使用非流传输，该传输将自动执行完整性检查。
注意：使用顶级gsutil -m标志时，不允许进行流传输。
切片对象下载
从Cloud Storage下载大型对象时，gsutil使用HTTP Range GET请求并行执行“切片”下载。这意味着临时下载目标文件的磁盘空间将被预先分配，并且文件中的字节范围（片）将被并行下载。一旦所有片均完成下载，该临时文件将被重命名为目标文件。此操作不需要其他本地磁盘空间。

此功能仅适用于Cloud Storage对象，因为它需要可用于校验切片的数据完整性的快速可组合校验和（CRC32C）。并且由于它依赖于CRC32C，因此使用切片对象下载还需要在执行下载的机器上编译ccmod（请参见gsutil help crcmod）。如果编译的crcmod不可用，则将执行未切片的对象下载。

注意：由于切片对象的下载会导致磁盘上各个位置发生多次写入，因此该机制可能会降低寻道时间较慢的磁盘的性能，特别是对于大量切片而言。虽然将切片的默认数量设置为很小以避免此问题，但是如果需要，可以通过将.boto配置文件中的“ sliced_object_download_threshold”变量设置为0来禁用切片的对象下载。
并行复合上传
gsutil可以自动使用 对象合成 对要上传到Cloud Storage的大型本地文件并行执行上传。如果启用（参见下文），则一个大文件将被拆分成多个组件，这些组件并行上传，然后在云中组成（最后删除了临时组件）。一个文件最多可分为32个组成部分。直到达到该部件限制，每个组件的最大大小由.boto配置文件的[GSUtil]部分中指定的变量“ parallel_composite_upload_component_size”确定（对于太大的文件，组件要需要装入32件）。此操作不需要其他本地磁盘空间。

使用并行复合上传会在上传性能和下载配置之间进行权衡：如果启用并行复合上传，则您的上传将运行得更快，但是有人需要安装编译的crcmod（请参阅gsutil帮助crcmod）在每台由gsutil或其他Python应用程序下载对象的计算机上。请注意，对于此类上载，无论是否启用了并行复合上载选项，都需要crcmod进行下载。对于某些发行版来说，这很容易（例如，它已预先安装在macOS上），但是在其他情况下，某些用户发现这很困难。因此，当前默认情况下禁用并行复合上传。Google正在积极与许多Linux发行版合作，以将crcmod包含在库存发行版中。完成后，我们将默认在gsutil中重新启用并行复合上传。

警告：并行复合上载不应与NEARLINE，COLDLINE或ARCHIVE存储类存储桶一起使用，因为这样做会导致每个组件对象的早期删除费用。
警告：在具有保留策略的存储桶中，不应使用并行复合上载 ，因为在每个组成部分都满足存储桶的最小保留期限之前，无法删除这些组件。
要尝试并行复合上传，可以运行以下命令：

gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp bigfile gs://your-bucket

其中bigfile大于150 MiB。执行此操作时，请注意，上传进度指示器会持续更新文件，直到上传的所有部分完成为止。如果在尝试此操作后要为以后的所有上载启用并行复合上载（尽管有前面提到的注意事项），则可以取消注释并将.boto配置文件中的“ parallel_composite_upload_threshold”配置值设置为此值。

请注意，crcmod问题仅影响通过Python应用程序（例如gsutil）的下载。如果所有需要使用gsutil或其他Python应用程序下载数据的用户都可以安装crcmod，或者如果没有Python用户需要下载您的对象，则启用并行复合上传是有意义的（请参见上文）。例如，如果您使用gsutil上传视频资产，而这些资产只能通过Java应用程序提供，那么在您的计算机上启用并行复合上传就很有意义（Java中提供了有效的CRC32C实现）。

如果在编写之前并行复合上载失败，则重新运行gsutil命令将利用失败组件的可恢复上载，并且在首次成功尝试后将删除组件对象。在成功完成上传之前，在gsutil失败之前成功上传的所有临时对象都将仍然存在。临时对象将以以下方式命名：

<random ID>/gsutil/tmp/parallel_composite_uploads/for_details_see/gsutil_help_cp/<hash>

其中，<random ID>是数字值，而<hash>是MD5哈希（与文件或对象内容的哈希无关）。

为了避免留下临时对象，您应该确保检查gsutil命令的退出状态。这可以在bash脚本中完成，例如，通过执行以下操作：

if ! gsutil cp ./local-file gs://your-bucket/your-object; then
  << Code that handles failures >>
fi

或者，要复制目录，请使用以下命令：

if ! gsutil cp -c -L cp.log -r ./dir gs://bucket; then
  << Code that handles failures >>
fi

请注意，使用并行复合上传上传的对象将具有CRC32C哈希，但不会具有MD5哈希（因此，下载该对象的用户必须安装crcmod，如前所述）。有关详细信息，请参见gsutil帮助crc32c。

通过将.boto配置文件中的“ parallel_composite_upload_threshold”变量设置为0，可以禁用并行复合上载。

更改临时目录
在多种情况下，gsutil会将数据写入临时目录：

压缩要上传的数据时（请参阅-z和-Z选项）
解压缩正在下载的数据时（例如，数据具有Content-Encoding：gzip时，例如，使用gsutil cp -z或gsutil cp -Z上载时发生的情况）
在运行集成测试时（使用gsutil test命令）
在这些情况下，gsutil默认选择的系统上的临时文件位置可能没有足够的空间。如果在其中一项操作中gsutil用完了空间（例如，在gsutil cp -z操作期间引发了“ CommandException：可用的临时空间不足，无法压缩<your file>”），则可以通过设置以下内容来更改写入这些临时文件的位置TMPDIR环境变量。在Linux和macOS上，您可以通过以下方式运行gsutil来执行此操作：

TMPDIR=/some/directory gsutil cp ...

或者通过将以下行添加到〜/ .bashrc文件中，然后在运行gsutil之前重新启动外壳程序：

export TMPDIR=/some/directory

在Windows 7上，可以从“开始”->“计算机”->“系统”->“高级系统设置”->“环境变量”更改TMPDIR环境变量。进行此更改后，您需要重新启动才能生效。（在Linux和macOS上运行export命令后，无需重新启动。）

同步特定于OS的文件类型（符号链接，设备等）
请参阅gsutil help rsync中有关特定于操作系统的文件类型的部分。尽管该部分是专门针对rsync命令编写的，但类似的点适用于cp命令。

选件
-a canned_acl	创建上传的对象时设置名为canned_acl的设置。有关更多详细信息，请参见“ gsutil帮助acls”。
-A	
从源存储桶/文件夹复制所有源版本。如果未设置，则仅复制每个源对象的实时版本。

注意：仅当目标存储桶已启用版本控制时，此选项才有用。
-c	
如果发生错误，请继续尝试复制其余文件。如果有任何副本失败，则即使设置了此标志，gsutil的退出状态也将为非零。运行“ gsutil -m cp ...”时会隐式设置此选项。

注意：-c仅适用于实际的复制操作。如果遍历本地目录中的文件时发生错误（例如，无效的Unicode文件名），gsutil将显示一条错误消息并中止。
-D	
以“菊花链”模式进行复制，即，通过运行gsutil的计算机在两个存储桶之间进行复制，方法是将下载挂接到钩子上。这与默认设置（在默认情况下，数据在“云端”中的两个存储桶之间）进行复制（即，无需通过运行gsutil的计算机进行复制）形成对比。

默认情况下，当源是复合对象时，“在云中复制”将保留该对象的复合性质。但是，可以使用菊花链模式将复合对象更改为非复合对象。例如：

gsutil cp -D -p gs://bucket/obj gs://bucket/obj_tmp
gsutil mv -p gs://bucket/obj_tmp gs://bucket/obj

注意：在提供商之间进行复制时（例如，将数据从Cloud Storage复制到另一个提供商），将自动使用菊花链模式。
-e	排除符号链接。指定后，将不会复制符号链接。
-I	使gsutil读取要从stdin复制的文件或对象的列表。这使您可以运行一个程序来生成要上传/下载的文件列表。
-j <ext,...>	
将gzip传输编码应用于扩展名与-j扩展名列表匹配的任何文件上载。当上传具有可压缩内容的文件（例如.js，.css或.html文件）时，此功能很有用，因为它可以节省网络带宽，同时还可以使数据在Cloud Storage中保持未压缩状态。

如果指定-j选项，则仅在内存中和在线压缩要上传的文件。本地文件和Cloud Storage对象均保持未压缩状态。上载的对象保留原始文件的Content-Type和名称。

请注意，如果要使用顶级-m选项与-j / -J选项一起并行化副本，则性能可能会受到“ max_upload_compression_buffer_size” boto config选项的限制，该选项默认设置为2 GiB。可以将压缩缓冲区的大小更改为更高的限制，例如：

gsutil -o "GSUtil:max_upload_compression_buffer_size=8G" \
  -m cp -j html -r /local/source/dir gs://bucket/path

-J	
将gzip传输编码应用于文件上传。该选项的作用类似于上述的-j选项，但是它适用于所有上载的文件，无论扩展名如何。

注意：如果使用此选项，但某些源文件压缩得不好（例如，二进制数据通常如此），此选项可能会导致上传时间更长。
-L <file>	
输出清单日志文件，其中包含有关复制的每个项目的详细信息。该清单包含每个项目的以下信息：

源路径。
目标路径。
源大小。
字节传输。
MD5哈希。
UTC日期和时间传输以ISO 8601格式开始。
UTC日期和时间传输已以ISO 8601格式完成。
上传ID（如果已执行可恢复的上传）。
尝试传输，成功或失败的最终结果。
故障详细信息（如果有）。
如果日志文件已经存在，则gsutil将使用该文件作为复制过程的输入，还将日志项附加到现有文件中。在现有日志文件中标记为已成功复制（或跳过）的文件/对象将被忽略。没有条目的文件/对象将被复制，以前标记为不成功的文件/对象将被重试。可以将其与-c选项一起使用，以构建脚本，该脚本使用bash脚本可靠地复制大量对象，如下所示：

until gsutil cp -c -L cp.log -r ./dir gs://bucket; do
  sleep 1
done

-c选项将导致故障发生后继续复制，并且-L选项将使gsutil在不重复的地方继续进行操作。只要gsutil以非零状态退出（该状态表示gsutil运行期间至少发生了一次故障），循环就会继续运行。

注意：如果您要同步目录和存储桶（或两个存储桶）的内容，请参见 gsutil help rsync。
-n	不客气。指定后，目标位置上的现有文件或对象将不会被覆盖。此选项跳过的任何项目都将报告为被跳过。此选项将执行附加的GET请求，以在尝试上载数据之前检查项目是否存在。这样可以节省重传的数据，但是额外的HTTP请求可能会使小型对象的传输变得更慢且更昂贵。
-p	
在云中复制时导致保留ACL。请注意，使用XML API时，此选项会影响性能和成本，因为它需要单独的HTTP调用才能与ACL进行交互。（当将-p选项与JSON API一起使用时，对性能或成本没有影响。）通过使用gsutil -m cp引起并行复制，可以在某种程度上缓解性能问题。请注意，仅当您拥有对所有复制对象的所有者访问权限时，此选项才有效。

如果希望目标存储桶中的所有对象都以相同的ACL结尾，可以避免使用cp -p的额外性能和成本，方法是在该存储桶上设置默认对象ACL，而不是使用cp -p。请参阅gsutil帮助defacl。

请注意，同时指定-a和-p选项是无效的。

-P	
导致在复制对象时保留POSIX属性。启用此功能后，gsutil cp将复制stat提供的字段。这些是所有者的用户ID，拥有组的组ID，文件的模式（权限）以及文件的访问/修改时间。对于下载，只有在启用了此标志的情况下上传源对象时，才设置这些属性。

在Windows上，此标志将仅设置和还原访问时间和修改时间。这是因为Windows没有POSIX uid / gid / mode的概念。

-R, -r	-R和-r选项是同义词。导致递归地复制目录，存储桶和存储桶子目录。如果您忽略使用此选项进行上传，则gsutil将复制找到的所有文件并跳过任何目录。同样，忽略为下载指定此选项将导致gsutil在当前存储桶目录级别复制任何对象，并跳过所有子目录。
-s <class>	目标对象的存储类。如果未指定，则使用目标存储桶的默认存储类。不适用于复制到非云目标。
-U	跳过对象类型不受支持的对象，而不是失败。不支持的对象类型是GLACIER存储类中的Amazon S3对象。
-v	请求打印每个上载对象的特定于版本的URL。有了此URL，您可以在以后进行并发更新时发出安全的上载请求，因为如果当前对象版本与特定于版本的URL不匹配，Cloud Storage将拒绝执行更新。有关更多详细信息，请参见 gsutil帮助版本。
-z <ext,...>	
将gzip内容编码应用于扩展名与-z扩展名列表匹配的任何文件上载。当上传具有可压缩内容的文件（例如.js，.css或.html文件）时，此功能很有用，因为它可以节省Cloud Storage中的网络带宽和空间，从而降低存储成本。

当指定-z选项时，文件中的数据在上载之前已被压缩，但实际文件在本地磁盘上未压缩。上载的对象保留原始文件的Content-Type和名称，但被赋予Content-Encoding标头，其值为“ gzip”，以指示存储的对象数据已在Cloud Storage服务器上压缩。

例如，以下命令：

gsutil cp -z html -a public-read \
  cattypes.html tabby.jpeg gs://mycats

将执行以下所有操作：

将文件cattypes.html和tabby.jpeg上传到存储桶gs：// mycats（cp命令）
将cattypes.html的Content-Type设置为text / html，将tabby.jpeg设置为image / jpeg（基于文件扩展名）
压缩文件cattypes.html中的数据（-z选项）
将cattypes.html的Content-Encoding设置为gzip（-z选项）
将两个文件的ACL都设置为公共读取（-a选项）
如果用户尝试在浏览器中查看cattypes.html，则浏览器将知道根据Content-Encoding标头解压缩数据，并根据Content-Type标头将其呈现为HTML。
由于-z / -Z选项在上传之前先压缩数据，因此它们不会受到可能影响-j / -J选项的压缩缓冲区瓶颈。

请注意，如果使用Content-Encoding：gzip下载对象，则gsutil会在写入本地文件之前解压缩内容。

-Z	
将gzip内容编码应用于文件上传。该选项的作用类似于上述的-z选项，但是它适用于所有上载的文件，无论扩展名如何。

警告：如果使用此选项，并且某些源文件压缩得不好（例如，二进制数据通常如此），则此选项可能会导致文件在云中占用的空间比未压缩时要多。

