package modules

import (
	"errors"
	"strings"

	"github.com/russross/blackfriday"
)

var nilContentERR = errors.New("content == nil")

func newMessage(message *Message) error {
	msg := message.Data.(map[string]interface{})

	// 读取channel数据
	v, err := db.Get([]byte(msg["channel"].(string)), nil)
	if err != nil {
		return err
	}
	// 解码channel数据
	var chanInfo channelInfo
	err = decode(v, &chanInfo)
	if err != nil {
		return err
	}

	// 检查是否为空信息
	// 去掉所有换行符
	if strings.Replace(msg["content"].(string), "<{#}>", "", -1) == "" {
		return nilContentERR
	}

	// 生成id
	id := newID()
	// 将当前信息id添加到channel的列表里
	chanInfo.MsgIDList = append([]string{id}, chanInfo.MsgIDList...)

	// 编码channel数据
	buf, err := encode(&chanInfo)
	if err != nil {
		return err
	}
	// 保存channel数据
	err = db.Put([]byte(msg["channel"].(string)), buf, nil)
	if err != nil {
		return err
	}

	// 编码msg数据
	var conInfo = &contentInfo{
		Content: toMarkdown(escape(msg["content"].(string))),
	}
	buf, err = encode(conInfo)
	if err != nil {
		return err
	}
	// 保存信息
	err = db.Put([]byte(msg["channel"].(string)+"_"+id), buf, nil)
	if err != nil {
		return err
	}

	// 将新信息推送到全部客户端
	conInfo.ID = id
	pushMessageToClient(conInfo)

	return nil
}

func escape(s string) string {
	s = strings.Replace(s, "<{#}>", "\n", -1)
	s = strings.Replace(s, "<", "&lt;", -1)
	s = strings.Replace(s, ">", "&gt;", -1)
	return s
}

func toMarkdown(s string) string {
	// set up the HTML renderer
	htmlFlags := 0
	htmlFlags |= blackfriday.HTML_USE_XHTML
	renderer := blackfriday.HtmlRenderer(htmlFlags, "", "")

	// set up the parser
	extensions := 0
	extensions |= blackfriday.EXTENSION_NO_INTRA_EMPHASIS
	extensions |= blackfriday.EXTENSION_TABLES
	extensions |= blackfriday.EXTENSION_FENCED_CODE
	extensions |= blackfriday.EXTENSION_AUTOLINK
	extensions |= blackfriday.EXTENSION_STRIKETHROUGH
	extensions |= blackfriday.EXTENSION_SPACE_HEADERS
	extensions |= blackfriday.EXTENSION_HEADER_IDS

	s = string(blackfriday.Markdown([]byte(s), renderer, extensions))
	return s
}

func pushMessageToClient(info *contentInfo) {
	for _, sender := range wsClientList {
		sender <- &Message{
			Type: "newMsg",
			Data: *info,
		}
	}
}

type Message struct {
	Type string
	Data interface{}
}